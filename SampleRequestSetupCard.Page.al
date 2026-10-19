page 50106 "Sample Request Setup Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Sample Request Setup";
    CAption = 'Sample Request Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Sample Request Nos."; Rec."Sample Request Nos.")
                {
                    ApplicationArea = All;
                    Caption = 'Sample Request Nos.';
                    ToolTip = 'Specifies the number of sample requests allowed for a customer.';
                }
                field("Default Max. Sample Qty."; Rec."Default Max. Sample Qty.")
                {
                    ApplicationArea = All;
                    Caption = 'Default Max. Sample Qty.';
                    ToolTip = 'Specifies the default maximum quantity of samples allowed for a customer.';
                }
                field("Max. Requests per Period"; Rec."Max. Requests per Period")
                {
                    ApplicationArea = All;
                    Caption = 'Max. Requests per Period';
                    ToolTip = 'Specifies the maximum number of sample requests allowed for a customer within a specified period.';
                }
                field("Request Period"; Rec."Request Period")
                {
                    ApplicationArea = All;
                    Caption = 'Request Period';
                    ToolTip = 'Specifies the period for which a customer can make sample requests.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.InsertIfNotExist();
    end;


}