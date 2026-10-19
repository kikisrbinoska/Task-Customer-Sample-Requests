page 50101 "Sample Requests List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sample Request Header";
    Caption = 'Sample Requests';
    Editable = false;
    CardPageId = "Sample Requests Card";



    layout
    {
        area(Content)
        {
            repeater(Samples)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    Tooltip = 'Specifies the unique number of the sample request.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    Tooltip = 'Specifies the customer number for the sample request.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    Tooltip = 'Specifies the name of the customer for the sample request.';
                }
                field(RequestDate; Rec."Request Date")
                {
                    ApplicationArea = All;
                    Caption = 'Request Date';
                    Tooltip = 'Specifies the date when the sample request was created.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Tooltip = 'Specifies the status of the sample request.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    ToolTip = 'Specifies the total amount of the sample request.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Print)
            {
                ApplicationArea = All;
                Caption = 'Print';
                ToolTip = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SampleRequestHeader: Record "Sample Request Header";
                begin
                    CurrPage.SetSelectionFilter(SampleRequestHeader);
                    Report.Run(Report::"Report Sample Request", true, false, SampleRequestHeader);
                end;

            }
        }
    }

}