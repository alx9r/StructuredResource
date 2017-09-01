Add-Type @'
        [System.AttributeUsage(System.AttributeTargets.Property | System.AttributeTargets.Field)]
        public class StructuredDscAttribute : System.Attribute {
            private bool hint;

            public virtual bool Hint
            {
                get { return hint; }
                set { hint = value; }
            }
        }
'@