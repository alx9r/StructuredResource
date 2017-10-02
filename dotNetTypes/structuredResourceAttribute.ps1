Add-Type @'
        [System.AttributeUsage(System.AttributeTargets.Property | System.AttributeTargets.Field)]
        public class StructuredResourceAttribute : System.Attribute {
            public enum ParameterTypeEnum
            {
                Property,
                Key,
                Hint,
                ConstructorProperty
            }
            private ParameterTypeEnum parameterType;

            public StructuredResourceAttribute() { }

            public StructuredResourceAttribute ( ParameterTypeEnum parameterType )
            {
                this.parameterType = parameterType;
            }

            public virtual ParameterTypeEnum ParameterType
            {
                get { return parameterType; }
            }
        }
'@
