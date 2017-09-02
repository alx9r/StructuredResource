Add-Type @'
        [System.AttributeUsage(System.AttributeTargets.Property | System.AttributeTargets.Field)]
        public class StructuredDscAttribute : System.Attribute {
            public enum ParameterTypeEnum
            {
                Property,
                Key,
                Hint,
                ConstructorProperty
            }
            private ParameterTypeEnum parameterType;

            public StructuredDscAttribute() { }

            public StructuredDscAttribute ( ParameterTypeEnum parameterType )
            {
                this.parameterType = parameterType;
            }

            public virtual ParameterTypeEnum ParameterType
            {
                get { return parameterType; }
            }
        }
'@