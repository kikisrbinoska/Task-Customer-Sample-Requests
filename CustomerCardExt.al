pageextension 50110 "Customer Card Extension" extends "Customer Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(CustomerSamples; "Customer Samples")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("Sample Requests")
            {
                ApplicationArea = All;
                Caption = 'Sample Requests';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Sample Requests List";
                RunPageLink = "Customer No." = field("No.");
            }
            action(NewSampleRequest)
            {
                ApplicationArea = All;
                Caption = 'New Sample Request';
                ToolTip = 'Create a new sample request for this customer.';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    SampleRequestMgt: Codeunit "Sample Request Mgt.";
                begin
                    SampleRequestMgt.CreateRequestForCustomer(Rec."No.");
                end;
            }
        }
    }
}