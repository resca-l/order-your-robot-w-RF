*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Archive
Library             Collections
Library             RPA.Desktop
Library             OperatingSystem
Library             RPA.Excel.Application
Library             RPA.RobotLogListener


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    # ToDo: Implement your keyword here
    Open the intranet website
    ${orders}=    Get orders
    Insert orders    ${orders}
    Archive receipts
    [Teardown]    Close the browser


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=    Read Table From CSV    orders.csv    header=True
    RETURN    ${table}

Insert orders
    [Arguments]    ${orders}
    FOR    ${order}    IN    @{orders}
        Fill and submit the form    ${order}
        ${number}=    Set Variable    ${order}[Order number]
        Store receipt as pdf    ${number}
        Screenshot robot    ${number}
        Embed screenshot to receipt    ${number}

        Click Button    id:order-another
    END

Store receipt as pdf
    [Arguments]    ${number}
    Wait Until Element Is Visible    id:order-completion
    ${receipt_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}/receipts${/}${number}_receipt.pdf

Screenshot robot
    [Arguments]    ${number}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}{/}receipts${/}${number}_robor_preview.png

Embed screenshot to receipt
    [Arguments]    ${number}
    ${list}=    Create List    ${OUTPUT_DIR}{/}receipts${/}${number}_receipt.pdf
    Add Files To Pdf    ${list}    ${OUTPUT_DIR}{/}receipts${/}${number}_robor_preview.png

Fill and submit the form
    [Arguments]    ${orders}
    Close annoying modal
    Select From List By Value    id:head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orders}[Legs]
    Input Text    address    ${orders}[Address]
    Wait Until Keyword Succeeds    10x    1s    Submit the order

Submit the order
    Mute Run On Failure    Page Should Contain Element
    Click Button    xpath://html/body/div/div/div[1]/div/div[1]/form/button[2]
    Page Should Contain Element    receipt

Close annoying modal
    Click Button    OK

Archive receipts
    Archive Folder With Zip    ${OUTPUT_DIR}{/}receipts    ${OUTPUT_DIR}{/}all_the_receipts.zip

Close the browser
    Close Browser
