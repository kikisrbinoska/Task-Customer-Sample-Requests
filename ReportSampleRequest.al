report 50101 "Report Sample Request"
{
    Caption = 'Report Sample Request';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/SampleRequest.rdl';

    dataset
    {
        dataitem("Sample Request Header"; "Sample Request Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Customer No.";
            column(CompanyName; CompanyInformation.Name)
            {

            }
            column(No; "No.")
            {
                IncludeCaption = true;
            }
            column(RequestDate; Format("Request Date"))
            {

            }
            column(Customer_Name; "Customer Name")
            {
                IncludeCaption = true;
            }
            column(ContactEmail; "Contact Email")
            {
                IncludeCaption = true;
            }
            dataitem("Sample Request Line"; "Sample Request Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(ItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Description; Description)
                {
                    IncludeCaption = true;
                }
                column(Quantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(Unit_of_Measure_Code; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
            }
        }
    }
    labels
    {
        ReportTitleLbl = 'Sample Request';
        RequestDateLbl = 'Request Date';
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";


}