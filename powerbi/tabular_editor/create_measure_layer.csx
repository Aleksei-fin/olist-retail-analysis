// Tabular Editor 2 Advanced Scripting
// Creates the Power BI measure layer from powerbi/measures.md.
//
// Usage:
// 1. Open powerbi/pbix/olist_finance_analytics.pbix in Power BI Desktop.
// 2. Run this script from the repository root using Tabular Editor 2 Advanced Scripting, or use:
//    TabularEditor.exe -L -S "...\create_measure_layer.csx" -D

var projectRoot = System.IO.Directory.GetCurrentDirectory();
var measuresPath = System.IO.Path.Combine(projectRoot, "powerbi", "measures.md");

if (!System.IO.File.Exists(measuresPath))
{
    throw new System.IO.FileNotFoundException("Measure catalog not found.", measuresPath);
}

if (Model.Database.CompatibilityLevel < 1601)
{
    Model.Database.CompatibilityLevel = 1601;
}

var measureTable = Model.Tables.FirstOrDefault(t => t.Name == "_Measures");
if (measureTable == null)
{
    measureTable = Model.AddCalculatedTable("_Measures", "{ 0 }");
}

var currencySelector = Model.Tables.FirstOrDefault(t => t.Name == "Currency Selector");
if (currencySelector == null)
{
    currencySelector = Model.AddCalculatedTable(
        "Currency Selector",
        "DATATABLE ( \"Currency\", STRING, { { \"BRL\" }, { \"USD\" }, { \"EUR\" } } )"
    );
}

currencySelector.Description = "Disconnected currency selector for BRL/USD/EUR reporting.";

var pnlBridge = Model.Tables.FirstOrDefault(t => t.Name == "P&L Bridge");
if (pnlBridge == null)
{
    pnlBridge = Model.AddCalculatedTable(
        "P&L Bridge",
        "DATATABLE ( \"P&L Step\", STRING, \"Sort Order\", INTEGER, { { \"Gross Revenue\", 1 }, { \"COGS\", 2 }, { \"Waste\", 3 }, { \"Delivery\", 4 }, { \"Payment Fees\", 5 }, { \"Marketing\", 6 }, { \"OPEX\", 7 }, { \"Tax\", 8 }, { \"Net Profit\", 9 } } )"
    );
}

pnlBridge.Description = "Disconnected ordered P&L bridge table for Executive Overview waterfall visuals.";

var pnlStepColumn = pnlBridge.Columns.FirstOrDefault(c => c.Name == "P&L Step");
var pnlSortColumn = pnlBridge.Columns.FirstOrDefault(c => c.Name == "Sort Order");
if (pnlStepColumn != null && pnlSortColumn != null)
{
    pnlStepColumn.SortByColumn = pnlSortColumn;
    pnlSortColumn.IsHidden = true;
}

measureTable.Description = "Dedicated measure table for the Olist Retail Finance Analytics Power BI report.";
measureTable.IsHidden = false;

foreach (var column in measureTable.Columns)
{
    column.IsHidden = true;
}

var markdown = System.IO.File.ReadAllText(measuresPath);
var currentFolder = "Unassigned";
var inDaxBlock = false;
var daxLines = new System.Collections.Generic.List<string>();
var created = 0;
var updated = 0;

var tableNameMap = new System.Collections.Generic.Dictionary<string, string>
{
    { "rpt_powerbi_sales_profitability", "sales_profitability" },
    { "rpt_powerbi_monthly_pnl", "monthly_pnl" },
    { "rpt_powerbi_daily_pnl", "daily_pnl" },
    { "rpt_powerbi_delivery", "delivery" },
    { "rpt_powerbi_payments", "payments" },
    { "rpt_powerbi_customer_cohorts", "customer_cohorts" },
    { "rpt_powerbi_customer_metrics", "customer_metrics" },
    { "rpt_powerbi_marketing_efficiency", "marketing_efficiency" }
};

var selectedCurrencyMoneyMeasures = new System.Collections.Generic.HashSet<string>(System.StringComparer.OrdinalIgnoreCase)
{
    "P&L Gross Revenue Selected Currency",
    "P&L COGS Selected Currency",
    "P&L Waste Selected Currency",
    "P&L Delivery Selected Currency",
    "P&L Payment Fees Selected Currency",
    "P&L Marketing Selected Currency",
    "P&L Pre-Marketing Contribution Margin Selected Currency",
    "P&L Contribution Margin Selected Currency",
    "P&L Contribution Margin After Marketing Selected Currency",
    "P&L OPEX Selected Currency",
    "P&L Bridge Amount",
    "P&L COGS Statement",
    "P&L Waste Statement",
    "P&L Delivery Statement",
    "P&L Payment Fees Statement",
    "P&L Marketing Statement",
    "P&L OPEX Statement",
    "Simulated Tax Statement",
    "Pre-Marketing Contribution Margin Selected Currency",
    "Contribution Margin Selected Currency",
    "Contribution Margin After Marketing Selected Currency",
    "CM per Order Selected Currency",
    "Product Revenue Selected Currency",
    "Freight Revenue Selected Currency",
    "Gross Revenue Selected Currency",
    "AOV Selected Currency",
    "Average Item Revenue Selected Currency",
    "Gross Profit Selected Currency",
    "Adjusted Gross Profit Selected Currency",
    "Simulated COGS Selected Currency",
    "Simulated Waste Cost Selected Currency",
    "Simulated Delivery Cost Selected Currency",
    "Simulated Payment Fee Selected Currency",
    "Simulated Marketing Cost Selected Currency",
    "COGS Statement",
    "Waste Statement",
    "Delivery Statement",
    "Payment Fees Statement",
    "Marketing Statement",
    "Daily Gross Revenue Selected Currency",
    "Daily COGS Selected Currency",
    "Daily Waste Selected Currency",
    "Daily Delivery Selected Currency",
    "Daily Payment Fees Selected Currency",
    "Daily Marketing Selected Currency",
    "Daily COGS Statement",
    "Daily Waste Statement",
    "Daily Delivery Statement",
    "Daily Payment Fees Statement",
    "Daily Marketing Statement",
    "Daily Pre-Marketing Contribution Margin Selected Currency",
    "Daily Contribution Margin Selected Currency",
    "Daily CM After Marketing Selected Currency",
    "Daily AOV Selected Currency",
    "Payment Value Selected Currency",
    "Payment Fees Selected Currency",
    "Average Payment Value Selected Currency",
    "Cost per Transaction Selected Currency",
    "Delivery Gross Revenue Selected Currency",
    "Delivery Freight Revenue Selected Currency",
    "Delivery Cost Selected Currency",
    "Delivery Cost per Order Selected Currency",
    "Delivery Fixed Cost per Order Selected Currency",
    "Freight Revenue per Delivery Order Selected Currency",
    "Logistics Margin Selected Currency",
    "Delivery CM Selected Currency",
    "Customer Total Revenue Selected Currency",
    "Customer Total CM Selected Currency",
    "Average Revenue LTV Selected Currency",
    "Average CM LTV Selected Currency",
    "Marketing Efficiency Cost Selected Currency",
    "Marketing Efficiency Revenue Selected Currency",
    "Revenue 7D Avg",
    "CM After Marketing 7D Avg",
    "OPEX Fixed G&A Selected Currency",
    "OPEX Variable Ops Selected Currency",
    "OPEX Infrastructure Step Cost Selected Currency",
    "Operating Profit Selected Currency",
    "Net Profit Selected Currency",
    "Simulated Tax Selected Currency",
    "Estimated CAC Selected Currency",
    "Marketing Cost Selected Currency"
};

var dynamicCurrencyFormatStringExpression = @"SWITCH (
    SELECTEDVALUE ( 'Currency Selector'[Currency], ""BRL"" ),
    ""BRL"", ""R$#,0.00;-R$#,0.00;R$0.00"",
    ""USD"", ""$#,0.00;-$#,0.00;$0.00"",
    ""EUR"", ""€#,0.00;-€#,0.00;€0.00"",
    ""R$#,0.00;-R$#,0.00;R$0.00""
)";

var allLines = markdown.Replace("\r\n", "\n").Split('\n');

foreach (var rawLine in allLines)
{
    var line = rawLine.TrimEnd();

    if (line.StartsWith("## "))
    {
        var heading = line.Substring(3).Trim();
        if (heading.StartsWith("Core Revenue", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Revenue";
        else if (heading.StartsWith("Cost", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Costs";
        else if (heading.StartsWith("Contribution Margin", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Margins";
        else if (heading.StartsWith("P&L", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "P&L";
        else if (heading.StartsWith("Scenario", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Scenarios";
        else if (heading.StartsWith("Daily", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Daily Monitoring";
        else if (heading.StartsWith("Payment", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Payments";
        else if (heading.StartsWith("Delivery", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Delivery";
        else if (heading.StartsWith("Customer", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Customers & Growth";
        else if (heading.StartsWith("Benchmarking", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Benchmarking";
        else if (heading.StartsWith("Currency", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Currency";
        else if (heading.StartsWith("Data Integrity", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Data Quality";
        else if (heading.StartsWith("Helper", System.StringComparison.OrdinalIgnoreCase)) currentFolder = "Helpers";
        else currentFolder = heading;
        continue;
    }

    if (line.Trim().Equals("```DAX", System.StringComparison.OrdinalIgnoreCase))
    {
        inDaxBlock = true;
        daxLines.Clear();
        continue;
    }

    if (inDaxBlock && line.Trim().Equals("```", System.StringComparison.Ordinal))
    {
        var dax = string.Join("\n", daxLines).Trim();
        if (!string.IsNullOrWhiteSpace(dax))
        {
            var match = System.Text.RegularExpressions.Regex.Match(dax, @"^\s*(?<name>[^\r\n=]+?)\s*=\s*(?<expr>[\s\S]+)$");
            if (match.Success)
            {
                var name = match.Groups["name"].Value.Trim();
                var expression = match.Groups["expr"].Value.Trim();

                foreach (var tableName in tableNameMap)
                {
                    expression = expression.Replace("'" + tableName.Key + "'", "'" + tableName.Value + "'");
                }

                var measure = measureTable.Measures.FirstOrDefault(m => m.Name.Equals(name, System.StringComparison.OrdinalIgnoreCase));
                if (measure == null)
                {
                    measure = measureTable.AddMeasure(name, expression);
                    created = created + 1;
                }
                else
                {
                    measure.Expression = expression;
                    updated = updated + 1;
                }

                var lowerName = name.ToLowerInvariant();
                var formatString = "#,0";

                if (lowerName.Contains("%") || lowerName.Contains("rate") || lowerName.Contains("margin") || lowerName.Contains("mix"))
                {
                    formatString = "0.0%;-0.0%;0.0%";
                }
                else if (lowerName.EndsWith(" usd") || lowerName.Contains(" usd "))
                {
                    formatString = "\"USD\" #,0.00;(\"USD\" #,0.00);\"USD\" #,0.00";
                }
                else if (lowerName.EndsWith(" eur") || lowerName.Contains(" eur "))
                {
                    formatString = "\"EUR\" #,0.00;(\"EUR\" #,0.00);\"EUR\" #,0.00";
                }
                else if (lowerName == "selected currency")
                {
                    formatString = "";
                }
                else if (lowerName.Contains("selected currency"))
                {
                    formatString = "#,0.00;(#,0.00);#,0.00";
                }
                else if (
                    lowerName.Contains("revenue")
                    || lowerName.Contains("payment")
                    || lowerName.Contains("fee")
                    || lowerName.Contains("cost")
                    || lowerName.Contains("cogs")
                    || lowerName.Contains("waste")
                    || lowerName.Contains("profit")
                    || lowerName.Contains("tax")
                    || lowerName.Contains("opex")
                    || lowerName.Contains("aov")
                    || lowerName.Contains("ltv")
                    || lowerName.Contains("cac")
                    || lowerName.Contains("roas")
                    || lowerName.Contains("logistics margin")
                )
                {
                    formatString = "\"R$\" #,0.00;(\"R$\" #,0.00);\"R$\" #,0.00";
                }
                else if (lowerName.Contains("warning") || lowerName.Contains("status") || lowerName.Contains("scenario"))
                {
                    formatString = "";
                }

                measure.DisplayFolder = currentFolder;
                if (selectedCurrencyMoneyMeasures.Contains(name))
                {
                    measure.FormatString = "";
                    measure.FormatStringExpression = dynamicCurrencyFormatStringExpression;
                }
                else
                {
                    measure.FormatStringExpression = "";
                    measure.FormatString = formatString;
                }
                measure.Description = "Generated from powerbi/measures.md. Folder: " + currentFolder + ".";
            }
            else
            {
                Warning("Skipped DAX block because it does not look like a measure: " + dax.Split('\n')[0]);
            }
        }

        inDaxBlock = false;
        daxLines.Clear();
        continue;
    }

    if (inDaxBlock)
    {
        daxLines.Add(line);
    }
}

Info("Measure layer complete. Created: " + created + ". Updated: " + updated + ".");
