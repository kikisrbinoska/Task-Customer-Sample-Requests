page 50104 "Sample Requests Card"
{
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "Sample Request Header";
    Caption = 'Sample Request Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = IsEditable;

                field("No."; Rec."No.")
                {
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer number for the sample request.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer for the sample request.';
                }
                field("Contact Email"; Rec."Contact Email")
                {
                    ApplicationArea = All;
                    Caption = 'Contact Email';
                    ToolTip = 'Specifies the email address of the contact person for the sample request.';
                }
                field(Project; Rec.Project)
                {
                    ApplicationArea = All;
                    Caption = 'Project';
                    ToolTip = 'Specifies the project number associated with the sample request.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    Caption = 'Request Date';
                    ToolTip = 'Specifies the date when the sample request was created.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the sample request.';
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    Caption = 'Requested By';
                    ToolTip = 'Specifies the name of the person who requested the sample.';
                }
            }
            part(Lines; "Sample Request List Part")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                Editable = IsEditable;
            }
            group(Approval)
            {

                field("Approved By"; Rec."Approved By") { }
                field("Approved Date"; Rec."Approved Date") { }
                field("Rejection Reason"; Rec."Rejection Reason") { }
                field("Tracking No."; Rec."Tracking No.") { }
                field("Shipped Date"; Rec."Shipped Date") { }
            }

        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        IsEditable := Rec.Status = Rec.Status::Open;
    end;

    var
        IsEditable: Boolean;
}