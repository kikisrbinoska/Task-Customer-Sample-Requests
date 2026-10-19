page 50104 "Sample Requests Card"
{
    PageType = Document;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the sample request.';
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
                    ToolTip = 'Specifies what the engineer is designing';
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
                    ToolTip = 'Specifies the user who created the sample request.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Total amount';
                    ToolTip = 'Specifies total amount';
                }
            }
            part(Lines; "Sample Request List Part")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                Editable = IsEditable;
                UpdatePropagation = Both;
            }
            group(Approval)
            {
                Caption = 'Approval and Shipping';
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who approved the sample request.';
                }
                field("Approved Date"; Rec."Approved Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the sample request was approved.';
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    Editable = IsPendingApproval;
                    ToolTip = 'Specifies why the sample request was rejected. Fill it in before you reject the request.';
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    Editable = IsApproved;
                    ToolTip = 'Specifies the tracking number of the shipment. Fill it in before you mark the request as shipped.';
                }
                field("Shipped Date"; Rec."Shipped Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the samples were shipped.';
                }
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(Submit)
            {
                ApplicationArea = All;
                Caption = 'Submit';
                ToolTip = 'Submit the sample request';
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    SampleRequestMgt.Submit(Rec);
                    CurrPage.Update(false);
                end;

            }
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                ToolTip = 'Approve the sample request';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    SampleRequestMgt.Approve(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reject)
            {
                ApplicationArea = All;
                Caption = 'Reject';
                ToolTip = 'Reject the sample request';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SampleRequestMgt.Reject(Rec);
                    CurrPage.Update(false);
                end;

            }
            action(MarkAsShipped)
            {
                ApplicationArea = All;
                Caption = 'Mark As shipped';
                ToolTip = 'Mark As shipped';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SampleRequestMgt.MarkAsShipped(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Caption = 'Cancel';
                ToolTip = 'Cancel request';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SampleRequestMgt.Cancel(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReOpen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                ToolTip = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SampleRequestMgt.ReopenRequest(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        IsEditable := Rec.Status = Rec.Status::Open;
        IsPendingApproval := Rec.Status = Rec.Status::"Pending Approval";
        IsApproved := Rec.Status = Rec.Status::Approved;
    end;

    var
        IsEditable: Boolean;
        IsPendingApproval: Boolean;
        IsApproved: Boolean;
        SampleRequestMgt: Codeunit "Sample Request Mgt.";
}