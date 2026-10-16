table 50101 "Sample Request Line"
{
    DataClassification = CustomerContent;
    Caption = 'Sample Request Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            TableRelation = "Sample Request Header"."No.";
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where("Sample Allowed" = const(true), Blocked = const(false));

            trigger OnValidate()
            var
                Item: Record Item;
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
            begin
                SampleRequestMgt.CheckOpenRequest();
                Item.Get(Rec);
                Item.TestField("Sample Allowed", true);
                Item.TestField(Blocked, false);
                Item.Description =
                 
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            Editable = false;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                SampleRequestMgt: Codeunit "Sample Request Mgt.";
-               begin
                if "Item No." <> '' then
                    SampleRequestMgt.CheckQuantity("Item No.", Quantity);
                UpdateLineAmount();
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
            Editable = false;
        }
        field(8; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            AutoFormatType = 2;
            Editable = false;
        }


    }
    keys
    {
        key(Pk; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
    local procedure UpdateLineAmount()
    begin
        "Line Amount" := Round(Quantity * "Unit Price");
    end;






}