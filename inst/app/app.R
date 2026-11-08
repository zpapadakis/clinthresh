# clinthresh web app
# Run locally with clinthresh::run_app(), or deploy this folder to shinyapps.io / Posit Connect.

library(shiny)
library(ggplot2)
if (requireNamespace("clinthresh", quietly = TRUE)) {
  library(clinthresh)
} else {
  stop("Install the clinthresh package first: remotes::install_github('zpapadakis/clinthresh')")
}

ref <- clinthresh::mcid_reference
ref$label <- paste0(ref$instrument, " - ", ref$subscale, ": ", ref$value, " ", ref$unit,
                    " (", sub(" [0-9]{4} .*", "", ref$source), ", ", ref$population, ")")

cite_text <- paste(
  "If this tool helped your work, please cite: Papadakis Z. Statistically significant, clinically",
  "meaningful, or neither? Clinical thresholds, equivalence testing, and replicability in",
  "sports medicine rehabilitation. Curr Phys Med Rehabil Rep. Manuscript under review.",
  "Software: Papadakis Z. clinthresh: clinical thresholds and equivalence tests (R package).")

fp <- function(p) if (p < 0.001) "< 0.001" else if (p < 0.01) sprintf("%.3f", p) else sprintf("%.2f", p)

theme_app <- if (requireNamespace("bslib", quietly = TRUE)) bslib::bs_theme(version = 5, bootswatch = "flatly") else NULL

ui <- fluidPage(
  theme = theme_app,
  tags$head(tags$style(HTML(".cite{font-size:0.9em;color:#555;border-top:1px solid #ddd;margin-top:24px;padding-top:12px}
                             .verdict{font-size:1.15em;font-weight:600;margin:8px 0}
                             pre{white-space:pre-wrap;font-family:inherit;font-size:1em}"))),
  titlePanel("Clinically meaningful, or not? A threshold toolkit for sports medicine research"),
  tabsetPanel(
    tabPanel("Interpret a result",
      sidebarLayout(
        sidebarPanel(
          radioButtons("rmode", "What are you doing?",
                       c("Reading a published trial (threshold not fixed by me in advance)" = "read",
                         "Planning or reporting my own trial (threshold fixed in advance)" = "plan")),
          p("Enter a between-group difference and its confidence interval as reported in a paper."),
          numericInput("lo", "Lower confidence limit", -6.5),
          numericInput("hi", "Upper confidence limit", 6.8),
          numericInput("est", "Point estimate (optional; blank = CI midpoint)", NA),
          selectInput("lvl", "Confidence level of the reported CI", c("95%" = 0.95, "90%" = 0.90, "99%" = 0.99)),
          numericInput("df", "Degrees of freedom (optional; blank = normal approximation)", NA),
          radioButtons("src", "Smallest change that matters to patients (threshold)",
                       c("Enter my own" = "own", "Pick from the reference table" = "table")),
          conditionalPanel("input.src == 'own'", numericInput("sesoi", "Threshold, in the same units as the difference", 8, min = 0)),
          conditionalPanel("input.src == 'table'", selectInput("refrow", NULL, ref$label, width = "100%")),
          textInput("units", "Units (for the sentence)", "points"),
          textInput("lab", "Label", "My trial")
        ),
        mainPanel(
          div(class = "verdict", textOutput("verdict")),
          textOutput("meaning"),
          plotOutput("plot", height = "220px"),
          tableOutput("tab"),
          h5("Sentence for your results or discussion"),
          verbatimTextOutput("sentence"),
          uiOutput("refnote")
        ))),
    tabPanel("Plan a trial",
      sidebarLayout(
        sidebarPanel(
          radioButtons("aim", "Aim", c("Equivalence (TOST)" = "eq", "Non-inferiority" = "ni")),
          radioButtons("des", "Design", c("Two parallel groups" = "two.sample", "Crossover / paired" = "paired")),
          numericInput("p_sesoi", "Smallest difference that matters (margin)", 8, min = 0),
          numericInput("p_sd", "Standard deviation (of the change scores, if crossover)", 20, min = 0),
          numericInput("p_true", "Expected true difference (usually 0)", 0),
          sliderInput("p_power", "Power", 0.7, 0.95, 0.8, 0.05),
          numericInput("p_alpha", "Alpha per one-sided test (0.025 matches a 95% CI)", 0.025, min = 0.001, max = 0.25)
        ),
        mainPanel(div(class = "verdict", textOutput("n_out")), textOutput("n_note"),
                  plotOutput("powercurve", height = "300px")))),
    tabPanel("Performance tests (SWC, MDC)",
      sidebarLayout(
        sidebarPanel(
          numericInput("t_sd", "Spread of scores between athletes (SD)", 7.85, min = 0),
          numericInput("t_icc", "Test-retest reliability (ICC)", 0.90, min = 0, max = 1, step = 0.01),
          numericInput("t_factor", "SWC factor (0.2 x SD is standard)", 0.2, min = 0, step = 0.1),
          selectInput("t_lvl", "MDC confidence", c("95%" = 0.95, "90%" = 0.90)),
          numericInput("t_n", "Size of the original study (for replications)", 25, min = 3),
          selectInput("t_type", "Original design", c("paired", "two.sample"))
        ),
        mainPanel(tableOutput("thr"),
                  p("If the MDC is larger than the SWC, a single test cannot detect a worthwhile change in an individual athlete; use repeated tests or a more reliable measure.")))),
    tabPanel("Reference table",
      p("Published thresholds for common sports medicine outcomes. Thresholds depend on population, anchor and method; read the source before using one."),
      tableOutput("reftab")),
    tabPanel("About",
      p("This app accompanies an invited review in Current Physical Medicine and Rehabilitation Reports and the clinthresh R package."),
      h4("How to read the five patterns"),
      tags$ul(
        tags$li(tags$b("Clinically important:"), " the whole confidence interval is beyond the smallest change that matters."),
        tags$li(tags$b("Real, importance unclear:"), " the interval excludes zero but reaches past the threshold."),
        tags$li(tags$b("Real but trivial:"), " the interval excludes zero but stays inside the threshold."),
        tags$li(tags$b("Practically equivalent:"), " the interval includes zero and stays inside the threshold."),
        tags$li(tags$b("Inconclusive:"), " the interval includes zero and reaches past the threshold. The study cannot tell.")),
      p("Technical note: every judgment uses the reported 95% CI (alpha = 0.025 per one-sided test, the CONSORT convention for equivalence and non-inferiority trials)."),
      p("Results from summary statistics are approximations. When raw data are available, analyze them directly (for example with the TOSTER package)."))
  ),
  div(class = "cite", cite_text)
)

server <- function(input, output, session) {
  thr <- reactive({
    if (input$src == "own") input$sesoi else ref$value_num[match(input$refrow, ref$label)]
  })
  res <- reactive({
    req(is.finite(input$lo), is.finite(input$hi), input$hi > input$lo, is.finite(thr()), thr() > 0)
    tost_ci(input$lo, input$hi, sesoi = thr(),
            estimate = if (is.na(input$est)) NULL else input$est,
            level = as.numeric(input$lvl), df = if (is.na(input$df)) Inf else input$df)
  })
  rd <- reactive(read_ci(input$lo, input$hi, estimate = if (is.na(input$est)) NULL else input$est,
                          threshold = thr(), level = as.numeric(input$lvl)))
  output$verdict <- renderText(paste("Pattern:", res()$pattern))
  output$meaning <- renderText(switch(sub(" \\(.*", "", res()$pattern),
    "Clinically important" = "What it means: the effect is real and large enough to matter to patients.",
    "Real, importance unclear" = "What it means: there is probably an effect, but we cannot tell if it is big enough to matter. More data are needed.",
    "Real but trivial" = "What it means: there is probably an effect, but it is too small to matter to patients.",
    "Practically equivalent" = "What it means: the two options give results that are close enough to be treated as the same for patients.",
    "Inconclusive" = "What it means: the study cannot tell. The result fits both no effect and an effect that matters. This is not evidence of no difference."))
  output$plot <- renderPlot({
    l <- list(res()); names(l) <- input$lab
    plot_equivalence(l, xlab = paste0("Difference (", input$units, ")"))
  })
  output$tab <- renderTable({
    r <- res()
    if (input$rmode == "read") {
      x <- rd()
      return(data.frame(Estimate = r$estimate, `Reported CI` = sprintf("%.2f to %.2f", r$ci_reported[1], r$ci_reported[2]),
                        `P (vs 0)` = fp(r$p_nhst), `Your threshold` = sprintf("%.2f", thr()),
                        `Equivalence holds for bounds >=` = sprintf("%.2f", x$equivalence_holds_for),
                        `Importance holds for thresholds <=` = if (is.na(x$importance_holds_for)) "none (CI includes zero)" else sprintf("%.2f", x$importance_holds_for),
                        check.names = FALSE))
    }
    data.frame(Estimate = r$estimate, `Reported CI` = sprintf("%.2f to %.2f", r$ci_reported[1], r$ci_reported[2]),
               `P (vs 0)` = fp(r$p_nhst), Bounds = sprintf("%.2f to %.2f", r$bounds[1], r$bounds[2]),
               `Equivalence CI` = sprintf("%.2f to %.2f", r$ci_equivalence[1], r$ci_equivalence[2]),
               `TOST P` = fp(r$p_tost), check.names = FALSE)
  }, digits = 2)
  output$sentence <- renderText({
    if (input$rmode == "plan") return(report_sentence(res(), units = input$units))
    x <- rd(); u <- if (nzchar(input$units)) paste0(" ", input$units) else ""
    paste0(sprintf("The difference was %.2f%s (%g%% CI %.2f to %.2f). ", x$estimate, u, 100 * x$level, x$ci[1], x$ci[2]),
           sprintf("The interval supports practical equivalence for any bound of %.2f%s or wider", x$equivalence_holds_for, u),
           if (is.na(x$importance_holds_for)) ", and because it includes zero it cannot show a clinically important effect. "
           else sprintf(" and a clinically important effect for any threshold up to %.2f%s. ", x$importance_holds_for, u),
           sprintf("Against a threshold of %.2f%s, the result is %s. ", thr(), u, tolower(x$pattern)),
           "No P value is given against this threshold, because it was not fixed before the result was seen.")
  })
  output$refnote <- renderUI({
    if (input$src != "table") return(NULL)
    i <- match(input$refrow, ref$label)
    tags$p(tags$em(sprintf("Threshold source: %s. %s. %s", ref$source[i], ref$method[i], ref$notes[i])))
  })
  n_req <- reactive({
    req(input$p_sesoi > 0, input$p_sd > 0)
    if (input$aim == "eq") n_equivalence(input$p_sesoi, input$p_sd, input$p_true, input$p_alpha, input$p_power, input$des)
    else n_noninferiority(input$p_sesoi, input$p_sd, input$p_true, input$p_alpha, input$p_power, input$des)
  })
  output$n_out <- renderText({
    unit <- if (input$des == "paired") "participants (pairs)" else "participants per group"
    sprintf("Required: %d %s", n_req(), unit)
  })
  output$n_note <- renderText("Plan around the smallest effect that matters, not around an effect reported in an earlier small study; add allowance for dropout.")
  output$powercurve <- renderPlot({
    req(input$aim == "eq")
    ns <- seq(5, max(20, 2 * n_req()), by = 1)
    pw <- vapply(ns, function(n) power_equivalence(n, input$p_sesoi, input$p_sd, input$p_true, input$p_alpha, input$des), numeric(1))
    ggplot(data.frame(n = ns, power = pw), aes(n, power)) + geom_line() +
      geom_hline(yintercept = input$p_power, linetype = "dashed") +
      labs(x = "Sample size", y = "Power of the equivalence test") + theme_classic(base_size = 13)
  })
  output$thr <- renderTable({
    s <- swc(sd = input$t_sd, factor = input$t_factor)
    se <- sem_icc(input$t_sd, input$t_icc)
    m <- mdc(sem = se, level = as.numeric(input$t_lvl))
    d33 <- small_telescope(input$t_n, input$t_type)
    data.frame(Quantity = c("Smallest worthwhile change", "Standard error of measurement",
                            paste0("Minimal detectable change (", 100 * as.numeric(input$t_lvl), "%)"),
                            "Small-telescopes bound (standardized d33)"),
               Value = c(s, se, m, d33))
  }, digits = 3)
  output$reftab <- renderTable(ref[, c("instrument", "subscale", "population", "threshold_type", "value", "unit", "level", "source", "notes")])
}

shinyApp(ui, server)
