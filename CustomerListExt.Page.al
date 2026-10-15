pageextension 50111 "Customer List Extension" extends "Customer List"
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
            action("New Sample Request")
            {
                ApplicationArea = All;
                Caption = 'New Sample Request';
                Image = NewDocument;

                trigger OnAction()
                var
                    SampleRequest: Record "Sample Request Header";
                begin
                    SampleRequest.Init();
                    SampleRequest.Validate("Customer No.", Rec."No.");
                    SampleRequest.Insert(true);
                    Page.Run(Page::"Sample Requests Card", SampleRequest);
                end;
            }
        }
    }
}