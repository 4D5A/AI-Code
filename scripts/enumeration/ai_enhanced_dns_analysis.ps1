<#
.SYNOPSIS
Generates an HTML report with DNS records (MX, SPF, DMARC, DKIM, and TXT) and AI-generated recommendations to improve security for a given domain.

.DESCRIPTION
Fetches email-security-relevant DNS records for a domain, sends them to an AI provider
(OpenAI's ChatGPT models or Anthropic's Claude models) for analysis, and writes a styled
HTML report containing both the collected records and the recommendations.

The API key is read from an environment variable and is never stored in this script:
  - OpenAI:  OPENAI_API_KEY
  - Claude:  ANTHROPIC_API_KEY

.PARAMETER Domain
The domain name for which the DNS records will be fetched.

.PARAMETER Provider
Which AI provider to use: "OpenAI" (default) or "Claude".

.PARAMETER Model
Optional model override. Defaults to "gpt-4" for OpenAI and "claude-sonnet-5" for Claude.

.EXAMPLE
$env:OPENAI_API_KEY = "<your key>"
.\ai_enhanced_dns_analysis.ps1 -Domain "example.com"

.EXAMPLE
$env:ANTHROPIC_API_KEY = "<your key>"
.\ai_enhanced_dns_analysis.ps1 -Domain "example.com" -Provider Claude
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Domain,

    [ValidateSet("OpenAI", "Claude")]
    [string]$Provider = "OpenAI",

    [string]$Model
)

function Get-DnsRecords {
    param (
        [string]$Domain,
        [string]$RecordType
    )
    try {
        $records = Resolve-DnsName -Name $Domain -Type $RecordType
        return $records
    } catch {
        Write-Error "Failed to get $RecordType records for $Domain"
        return @()
    }
}

function Query-AI {
    param (
        [string]$Prompt,
        [string]$Provider,
        [string]$Model
    )

    $systemPrompt = "You are an AI assistant that provides cybersecurity recommendations based on DNS records."

    switch ($Provider) {
        "OpenAI" {
            $apiKey = $env:OPENAI_API_KEY
            if ([string]::IsNullOrWhiteSpace($apiKey)) {
                throw "OPENAI_API_KEY environment variable is not set. Set it before running (e.g. `$env:OPENAI_API_KEY = '<your key>'`) and do not hard-code the key in this script."
            }
            if ([string]::IsNullOrWhiteSpace($Model)) { $Model = "gpt-4" }

            $apiUrl = "https://api.openai.com/v1/chat/completions"
            $body = @{
                model = $Model
                messages = @(@{
                    role = "system"; content = $systemPrompt
                }, @{
                    role = "user"; content = $Prompt
                })
                max_tokens = 1024
                temperature = 0.7
            } | ConvertTo-Json -Depth 10

            $headers = @{
                "Authorization" = "Bearer $apiKey"
                "Content-Type"  = "application/json"
            }

            try {
                $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
                return $response.choices[0].message.content.Trim()
            } catch {
                Write-Error "Failed to query OpenAI API: $_"
                return $null
            }
        }
        "Claude" {
            $apiKey = $env:ANTHROPIC_API_KEY
            if ([string]::IsNullOrWhiteSpace($apiKey)) {
                throw "ANTHROPIC_API_KEY environment variable is not set. Set it before running (e.g. `$env:ANTHROPIC_API_KEY = '<your key>'`) and do not hard-code the key in this script."
            }
            if ([string]::IsNullOrWhiteSpace($Model)) { $Model = "claude-sonnet-5" }

            $apiUrl = "https://api.anthropic.com/v1/messages"
            $body = @{
                model = $Model
                max_tokens = 1024
                system = $systemPrompt
                messages = @(@{
                    role = "user"; content = $Prompt
                })
            } | ConvertTo-Json -Depth 10

            $headers = @{
                "x-api-key"         = $apiKey
                "anthropic-version" = "2023-06-01"
                "Content-Type"      = "application/json"
            }

            try {
                $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
                return $response.content[0].text.Trim()
            } catch {
                Write-Error "Failed to query Anthropic API: $_"
                return $null
            }
        }
    }
}

function Generate-HtmlReport {
    param (
        [string]$Domain,
        [array]$MXRecords,
        [array]$SPFRecords,
        [array]$DMARCRecords,
        [array]$DKIMRecords,
        [array]$TXTRecords,
        [string]$Recommendations,
        [string]$Provider,
        [string]$Model
    )

    function ConvertTo-HtmlText {
        param ([string]$Text)
        return ($Text -replace "&", "&amp;" -replace "<", "&lt;" -replace ">", "&gt;")
    }

    function Format-RecordRows {
        param (
            [string]$Label,
            [array]$Records
        )
        if (-not $Records -or @($Records).Count -eq 0) {
            return "        <tr><td>$Label</td><td><em>None found</em></td></tr>"
        }
        $rows = foreach ($record in $Records) {
            if ($record.Strings) {
                $value = ($record.Strings -join " ")
            } elseif ($null -ne $record.Exchange) {
                $value = "Preference $($record.Preference), Exchange $($record.Exchange)"
            } else {
                $value = ($record | Out-String).Trim()
            }
            $value = ConvertTo-HtmlText -Text $value
            "        <tr><td>$Label</td><td>$value</td></tr>"
        }
        return ($rows -join "`n")
    }

    $recordRows = @(
        Format-RecordRows -Label "MX"    -Records $MXRecords
        Format-RecordRows -Label "SPF"   -Records $SPFRecords
        Format-RecordRows -Label "DMARC" -Records $DMARCRecords
        Format-RecordRows -Label "DKIM"  -Records $DKIMRecords
        Format-RecordRows -Label "TXT"   -Records $TXTRecords
    ) -join "`n"

    $recommendationsHtml = ConvertTo-HtmlText -Text $Recommendations
    $generated = (Get-Date).ToString("u")

    $html = @"
<html>
<head>
    <title>DNS Report for $Domain</title>
    <style>
        body { font-family: Segoe UI, Arial, sans-serif; margin: 2em; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 1.5em; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
        th { background-color: #f2f2f2; }
        pre { background-color: #f7f7f7; border: 1px solid #ddd; padding: 1em; white-space: pre-wrap; }
        .meta { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>DNS Report for $Domain</h1>
    <p class="meta">Generated $generated &middot; Analysis by $Provider ($Model)</p>
    <h2>DNS Records</h2>
    <table>
        <tr><th>Type</th><th>Value</th></tr>
$recordRows
    </table>
    <h2>Recommendations</h2>
    <pre>$recommendationsHtml</pre>
</body>
</html>
"@

    return $html
}

# Resolve the model default for reporting/labeling
if ([string]::IsNullOrWhiteSpace($Model)) {
    $Model = if ($Provider -eq "Claude") { "claude-sonnet-5" } else { "gpt-4" }
}

# Fetch DNS records
$MXRecords = Get-DnsRecords -Domain $Domain -RecordType "MX"
$SPFRecords = Get-DnsRecords -Domain $Domain -RecordType "TXT" | Where-Object { $_.Strings -match "v=spf1" }
$DMARCRecords = Get-DnsRecords -Domain $Domain -RecordType "TXT" | Where-Object { $_.Strings -match "v=DMARC1" }
$DKIMRecords = Get-DnsRecords -Domain $Domain -RecordType "TXT" | Where-Object { $_.Strings -match "DKIM" }
$TXTRecords = Get-DnsRecords -Domain $Domain -RecordType "TXT"

# Prepare prompt for AI
$dnsData = @{
    MX = $MXRecords | ForEach-Object { @{ Preference = $_.Preference; Exchange = $_.Exchange } }
    SPF = $SPFRecords | ForEach-Object { @{ SPFRecord = $_.Strings } }
    DMARC = $DMARCRecords | ForEach-Object { @{ DMARCRecord = $_.Strings } }
    DKIM = $DKIMRecords | ForEach-Object { @{ DKIMRecord = $_.Strings } }
    TXT = $TXTRecords | ForEach-Object { @{ TXTRecord = $_.Strings } }
} | ConvertTo-Json -Depth 10

$prompt = @"
Based on the following DNS records for the domain '$Domain', provide:
1. Recommended changes to improve email security and reliability.
2. Suggestions for enhancing the domain's overall security posture.


DNS Records:
$dnsData
"@

# Query the selected AI provider
Write-Output "Querying $Provider ($Model) for recommendations..."
$recommendations = Query-AI -Prompt $prompt -Provider $Provider -Model $Model

if ($recommendations) {
    # Generate HTML report
    $htmlReport = Generate-HtmlReport -Domain $Domain -MXRecords $MXRecords -SPFRecords $SPFRecords -DMARCRecords $DMARCRecords -DKIMRecords $DKIMRecords -TXTRecords $TXTRecords -Recommendations $recommendations -Provider $Provider -Model $Model

    # Save the HTML report
    $reportPath = "$Domain-DnsReport.html"
    $htmlReport | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Output "HTML report generated: $reportPath"
} else {
    Write-Error "Failed to retrieve recommendations from the $Provider API."
}
