// DomainIR.res - IR types for domain module generation
// Separate from the main IR (Schema→ReScript types), this describes
// domain modules: type t + let make function.

type fieldMapping =
  | Mapper(string) // "AdsSummaryMappers.adSales" → Fn(raw)
  | Passthrough(string) // "campaign" or "campaignStatus" → raw.field

type irDomainField = {
  name: string, // field name in domain type
  typeAnnotation: string, // "Metric.t", "string"
  mapping: fieldMapping,
}

type irDomainModule = {
  name: string, // "AdsSummary"
  sourceType: string, // "Api.getAdsExecutiveSummaryResponse"
  output: string, // "AdsSummary.gen.res"
  fields: array<irDomainField>,
}
