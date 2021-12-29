*** Settings ***
Documentation   My Test Robot.
Library     RPA.PDF
Library     RPA.HTTP
Library     RPA.Excel.Files
Library     RPA.Browser.Selenium
Task Teardown     Close Browser


### Define the keywords used in the robot ###

*** Keywords ***
Download the excel file
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True    target_file=${CURDIR}${/}data${/}SalesData.xlsx

*** Keywords ***
Open a website
    # Open Browser   https://robotsparebinindustries.com/    edge
    Open Available Browser   https://robotsparebinindustries.com/    headless=True

*** Keywords ***
Log in
    Input Text        id:username    maria
    Input Password    id:password    thoushallnotpass
    Submit Form       

*** Keywords ***
Fill And Submit The Form For One Person
    [Arguments]    ${sales_rep}
    Input Text                   firstname      ${sales_rep}[First Name]
    Input Text                   lastname       ${sales_rep}[Last Name]
    Input Text                   salesresult    ${sales_rep}[Sales]           #1st parameter is locator for id i.e. same as id:<name> shown above
    ${target_as_string}=    Convert To String   ${sales_rep}[Sales Target]    #Convert the 'Sales Target' string into num/int, so can be used as such in the dropdown
    Select From List By Value    salestarget    ${target_as_string}           #2nd parameter is the 'value' element, probably there are another keywords for 'Text' and 'Index'
    Click Button                 Submit                                       #Only one parameter needed for the keyword - text of the button; there might be an option for locator too

*** Keywords ***
Fill The Form Using The Data From The Excel File
    # Open the Excel file and read it
    Open Workbook    data/SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    # Call the 'fill in' function with each record as a parameter i.e. enter data for every person in the sheet
    FOR    ${sales_rep}    IN    @{sales_reps}
        Fill And Submit The Form For One Person    ${sales_rep}
    END

*** Keywords ***
Collect the results
    Screenshot    css:div.sales-summary    ${CURDIR}${/}output${/}sales_summary.png

*** Keywords ***
Export The Table As A PDF
    Wait Until Page Contains Element    id:sales-results
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML    # Get the HTML table data by locating the element that contains it
    Html To Pdf    ${sales_results_html}    ${CURDIR}${/}output${/}sales_results.pdf
    

### Define the tasks that the robot is going to run ###

*** Tasks ***
Download the latest Excel file and override the existing one
    Download the excel file

*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open a website
    Log in
    Wait Until Page Contains Element    id:sales-form
    Fill The Form Using The Data From The Excel File
    Collect the results                # Screenshot of the results
    Export The Table As A PDF          # PDF with the results

*** Tasks ***
Print an end message
    Log    That robot ran successfully