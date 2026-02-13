module S = Sury

@genType
@tag("_tag")
@unboxed
@schema
type stringOrInt = String(string) | Int(int)

@genType
@schema
type adsExecutiveSummaryResponseSchema = {
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>
}

@genType
@schema
type attributionExecutiveSummaryResponseSchema = {
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>
}

@genType
@schema
type cFOExecutiveSummaryResponseSchema = {
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>
}

@genType
@schema
type forecastParams = {
  ad_spend_what_if: @s.null Nullable.t<float>,
  ad_sales_what_if: @s.null Nullable.t<float>,
  ad_impressions_what_if: @s.null Nullable.t<float>,
  ad_clicks_what_if: @s.null Nullable.t<float>,
  ad_orders_what_if: @s.null Nullable.t<float>,
  ad_units_sold_what_if: @s.null Nullable.t<float>,
  organic_sales_what_if: @s.null Nullable.t<float>,
  organic_impressions_what_if: @s.null Nullable.t<float>,
  organic_clicks_what_if: @s.null Nullable.t<float>,
  organic_orders_what_if: @s.null Nullable.t<float>,
  organic_units_sold_what_if: @s.null Nullable.t<float>,
  attribution_sales_what_if: @s.null Nullable.t<float>,
  attribution_clicks_what_if: @s.null Nullable.t<float>,
  attribution_orders_what_if: @s.null Nullable.t<float>,
  attribution_units_sold_what_if: @s.null Nullable.t<float>,
  target_doi: @s.null Nullable.t<float>,
  lead_time_days: @s.null Nullable.t<int>
}

@genType
@schema
type insightResponse = {
  summary: string,
  date_start: string,
  date_end: string,
  asin: @s.null Nullable.t<string>,
  agent: string
}

@genType
@schema
type inventoryExecutiveSummaryResponseSchema = {
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryResponseSchema = {
  market_total_sales: @s.null Nullable.t<float>,
  brand_market_share: @s.null Nullable.t<float>,
  market_average_price: @s.null Nullable.t<float>,
  market_total_units_sold: @s.null Nullable.t<float>,
  market_asin_count: @s.null Nullable.t<int>,
  market_promotion_value: @s.null Nullable.t<float>,
  market_promotion_count: @s.null Nullable.t<int>,
  market_review_score: @s.null Nullable.t<float>,
  market_pos: @s.null Nullable.t<float>,
  market_ad_spend: @s.null Nullable.t<float>
}

@genType
@schema
type organicExecutiveSummaryResponseSchema = {
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>
}

@genType
@schema
type projectedMetric = {
  baseline: float,
  projected: @s.null Nullable.t<float>,
  diff: @s.null Nullable.t<float>,
  percent_diff: @s.null Nullable.t<float>
}

@genType
@schema
type strategicGoal = {
  metric: string,
  value: float,
  asin: @s.null Nullable.t<string>,
  date_start: @s.null Nullable.t<string>,
  date_end: @s.null Nullable.t<string>
}

@genType
@schema
type strategicTaskItem = {
  title: string,
  description: string,
  daily_net_profit: float,
  role: string
}

@genType
@schema
type totalExecutiveSummaryResponseSchema = {
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>
}

@genType
@schema
type whatifAppliedEntry = {
  current_value: @s.null Nullable.t<float>,
  percentage_change: float,
  target_value: @s.null Nullable.t<float>
}

@genType
@schema
type whatifModelInfo = {
  metrics_count: int,
  correlations_count: int,
  data_points: int
}

@genType
@schema
type validationError = {
  loc: array<stringOrInt>,
  msg: string,
  @as("type") type_: string,
  input: option<JSON.t>,
  ctx: option<{}>
}

@genType
@schema
type adsExecutiveSummaryWithForecastBreakdown = {
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>
}

@genType
@schema
type attributionExecutiveSummaryWithForecastBreakdown = {
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>
}

@genType
@schema
type cFOExecutiveSummaryWithForecastBreakdown = {
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>
}

@genType
@schema
type tierLevelForecastParams = {
  ad_spend_what_if: @s.null Nullable.t<float>,
  ad_sales_what_if: @s.null Nullable.t<float>,
  ad_impressions_what_if: @s.null Nullable.t<float>,
  ad_clicks_what_if: @s.null Nullable.t<float>,
  ad_orders_what_if: @s.null Nullable.t<float>,
  ad_units_sold_what_if: @s.null Nullable.t<float>,
  organic_sales_what_if: @s.null Nullable.t<float>,
  organic_impressions_what_if: @s.null Nullable.t<float>,
  organic_clicks_what_if: @s.null Nullable.t<float>,
  organic_orders_what_if: @s.null Nullable.t<float>,
  organic_units_sold_what_if: @s.null Nullable.t<float>,
  attribution_sales_what_if: @s.null Nullable.t<float>,
  attribution_clicks_what_if: @s.null Nullable.t<float>,
  attribution_orders_what_if: @s.null Nullable.t<float>,
  attribution_units_sold_what_if: @s.null Nullable.t<float>,
  target_doi: @s.null Nullable.t<float>,
  lead_time_days: @s.null Nullable.t<int>,
  no_sales: @s.null Nullable.t<forecastParams>,
  poor: @s.null Nullable.t<forecastParams>,
  mid: @s.null Nullable.t<forecastParams>,
  good: @s.null Nullable.t<forecastParams>
}

@genType
@schema
type getV1MathInsightsTotalResponse = insightResponse

@genType
@schema
type getV1MathInsightsMarketResponse = insightResponse

@genType
@schema
type getV1MathInsightsAdsResponse = insightResponse

@genType
@schema
type getV1MathInsightsOrganicResponse = insightResponse

@genType
@schema
type getV1MathInsightsAttributionResponse = insightResponse

@genType
@schema
type getV1MathInsightsCfoResponse = insightResponse

@genType
@schema
type getV1MathInsightsInventoryResponse = insightResponse

@genType
@schema
type inventoryExecutiveSummaryWithForecastBreakdown = {
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  market_total_sales: @s.null Nullable.t<float>,
  brand_market_share: @s.null Nullable.t<float>,
  market_average_price: @s.null Nullable.t<float>,
  market_total_units_sold: @s.null Nullable.t<float>,
  market_asin_count: @s.null Nullable.t<int>,
  market_promotion_value: @s.null Nullable.t<float>,
  market_promotion_count: @s.null Nullable.t<int>,
  market_review_score: @s.null Nullable.t<float>,
  market_pos: @s.null Nullable.t<float>,
  market_ad_spend: @s.null Nullable.t<float>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>
}

@genType
@schema
type organicExecutiveSummaryWithForecastBreakdown = {
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}

@genType
@schema
type timelineDataPoint_OrganicExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: organicExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: organicExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>
}

@genType
@schema
type strategicPlanResponse = {
  plan: string,
  forecast_period: string,
  metrics: option<Dict.t<projectedMetric>>,
  strategic_tasks: option<array<strategicTaskItem>>,
  projected_total_sales: float,
  projected_net_profit: float,
  projected_gross_profit: float,
  projected_roi: float,
  total_sales_diff_pct: @s.null Nullable.t<float>,
  net_profit_diff_pct: @s.null Nullable.t<float>,
  gross_profit_diff_pct: @s.null Nullable.t<float>,
  roi_diff_pct: @s.null Nullable.t<float>,
  goals: option<array<strategicGoal>>,
  asin: @s.null Nullable.t<string>
}

@genType
@schema
type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>
}

@genType
@schema
type totalExecutiveSummaryWithForecastBreakdown = {
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}

@genType
@schema
type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: totalExecutiveSummaryResponseSchema,
  projected: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  percent_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_value: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>
}

@genType
@schema
type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: adsExecutiveSummaryResponseSchema,
  percent_diff: adsExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: attributionExecutiveSummaryResponseSchema,
  percent_diff: attributionExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: cFOExecutiveSummaryResponseSchema,
  percent_diff: cFOExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: inventoryExecutiveSummaryResponseSchema,
  percent_diff: inventoryExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: marketIntelligenceExecutiveSummaryResponseSchema,
  percent_diff: marketIntelligenceExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: organicExecutiveSummaryResponseSchema,
  percent_diff: organicExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: totalExecutiveSummaryResponseSchema,
  percent_diff: totalExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}

@genType
@schema
type hTTPValidationError = {
  detail: option<array<validationError>>
}

@genType
@schema
type timelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type timelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type getV1MathInsightsStrategicPlanResponse = strategicPlanResponse

@genType
@schema
type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}

@genType
@tag("_tag")
@schema
type getV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<adsExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: @s.null Nullable.t<float>,
  ad_spend: @s.null Nullable.t<float>,
  ad_impressions: @s.null Nullable.t<float>,
  ad_ctr: @s.null Nullable.t<float>,
  ad_clicks: @s.null Nullable.t<float>,
  ad_cvr: @s.null Nullable.t<float>,
  ad_orders: @s.null Nullable.t<float>,
  ad_units_sold: @s.null Nullable.t<float>,
  acos: @s.null Nullable.t<float>,
  roas: @s.null Nullable.t<float>,
  cpc: @s.null Nullable.t<float>,
  cpm: @s.null Nullable.t<float>,
  time_in_budget: @s.null Nullable.t<float>,
  ad_tos_is: @s.null Nullable.t<float>,
  ads_non_optimal_spend: @s.null Nullable.t<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: adsExecutiveSummaryResponseSchema,
  percent_diff: adsExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<attributionExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null Nullable.t<float>,
  attribution_spend: @s.null Nullable.t<float>,
  attribution_impressions: @s.null Nullable.t<float>,
  attribution_ctr: @s.null Nullable.t<float>,
  attribution_clicks: @s.null Nullable.t<float>,
  attribution_cvr: @s.null Nullable.t<float>,
  attribution_orders: @s.null Nullable.t<float>,
  attribution_units_sold: @s.null Nullable.t<float>,
  attribution_acos: @s.null Nullable.t<float>,
  attribution_roas: @s.null Nullable.t<float>,
  attribution_cpc: @s.null Nullable.t<float>,
  attribution_cpm: @s.null Nullable.t<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: attributionExecutiveSummaryResponseSchema,
  percent_diff: attributionExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<cFOExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null Nullable.t<float>,
  frozen_capital: @s.null Nullable.t<float>,
  borrowed_capital: @s.null Nullable.t<float>,
  gross_profit: @s.null Nullable.t<float>,
  gross_margin: @s.null Nullable.t<float>,
  contribution_profit: @s.null Nullable.t<float>,
  contribution_margin: @s.null Nullable.t<float>,
  net_profit: @s.null Nullable.t<float>,
  net_margin: @s.null Nullable.t<float>,
  opex: @s.null Nullable.t<float>,
  roi: @s.null Nullable.t<float>,
  cost_of_goods_sold: @s.null Nullable.t<float>,
  amazon_fees: @s.null Nullable.t<float>,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: cFOExecutiveSummaryResponseSchema,
  percent_diff: cFOExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathInventoryExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<inventoryExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathInventoryExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null Nullable.t<float>,
  fbt_in_stock_rate: @s.null Nullable.t<float>,
  three_pl_in_stock_rate: @s.null Nullable.t<float>,
  storage_costs: @s.null Nullable.t<float>,
  shipping_costs: @s.null Nullable.t<float>,
  forecasting_accuracy: @s.null Nullable.t<float>,
  inventory_turnover: @s.null Nullable.t<float>,
  safety_stock: @s.null Nullable.t<float>,
  doi_available: @s.null Nullable.t<float>,
  total_doi: @s.null Nullable.t<float>,
  estimated_stock_out_date: @s.null Nullable.t<string>,
  available_stock: @s.null Nullable.t<float>,
  in_transit: @s.null Nullable.t<float>,
  receiving: @s.null Nullable.t<float>,
  total_available: @s.null Nullable.t<float>,
  units_to_order: @s.null Nullable.t<int>,
  recommended_order_date: @s.null Nullable.t<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: inventoryExecutiveSummaryResponseSchema,
  percent_diff: inventoryExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null Nullable.t<float>,
  brand_market_share: @s.null Nullable.t<float>,
  market_average_price: @s.null Nullable.t<float>,
  market_total_units_sold: @s.null Nullable.t<float>,
  market_asin_count: @s.null Nullable.t<int>,
  market_promotion_value: @s.null Nullable.t<float>,
  market_promotion_count: @s.null Nullable.t<int>,
  market_review_score: @s.null Nullable.t<float>,
  market_pos: @s.null Nullable.t<float>,
  market_ad_spend: @s.null Nullable.t<float>
}) | TimelineResponse({
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null Nullable.t<float>,
  brand_market_share: @s.null Nullable.t<float>,
  market_average_price: @s.null Nullable.t<float>,
  market_total_units_sold: @s.null Nullable.t<float>,
  market_asin_count: @s.null Nullable.t<int>,
  market_promotion_value: @s.null Nullable.t<float>,
  market_promotion_count: @s.null Nullable.t<int>,
  market_review_score: @s.null Nullable.t<float>,
  market_pos: @s.null Nullable.t<float>,
  market_ad_spend: @s.null Nullable.t<float>
}) | MarketIntelligenceExecutiveSummaryWithForecastBreakdown({
  market_total_sales: @s.null Nullable.t<float>,
  brand_market_share: @s.null Nullable.t<float>,
  market_average_price: @s.null Nullable.t<float>,
  market_total_units_sold: @s.null Nullable.t<float>,
  market_asin_count: @s.null Nullable.t<int>,
  market_promotion_value: @s.null Nullable.t<float>,
  market_promotion_count: @s.null Nullable.t<int>,
  market_review_score: @s.null Nullable.t<float>,
  market_pos: @s.null Nullable.t<float>,
  market_ad_spend: @s.null Nullable.t<float>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: marketIntelligenceExecutiveSummaryResponseSchema,
  percent_diff: marketIntelligenceExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: organicExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<organicExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: @s.null Nullable.t<float>,
  organic_impressions: @s.null Nullable.t<float>,
  organic_ctr: @s.null Nullable.t<float>,
  organic_clicks: @s.null Nullable.t<float>,
  organic_cvr: @s.null Nullable.t<float>,
  organic_orders: @s.null Nullable.t<float>,
  organic_units_sold: @s.null Nullable.t<float>,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: organicExecutiveSummaryResponseSchema,
  percent_diff: organicExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null Nullable.t<totalExecutiveSummaryResponseSchema>
})

@genType
@tag("_tag")
@schema
type postV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null Nullable.t<float>,
  total_spend: @s.null Nullable.t<float>,
  total_impressions: @s.null Nullable.t<float>,
  ctr: @s.null Nullable.t<float>,
  total_clicks: @s.null Nullable.t<float>,
  cvr: @s.null Nullable.t<float>,
  total_orders: @s.null Nullable.t<float>,
  total_units_sold: @s.null Nullable.t<float>,
  total_ntb_orders: @s.null Nullable.t<float>,
  tacos: @s.null Nullable.t<float>,
  mer: @s.null Nullable.t<float>,
  lost_sales: @s.null Nullable.t<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: totalExecutiveSummaryResponseSchema,
  percent_diff: totalExecutiveSummaryResponseSchema,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
}) | TimelineResponse({
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null Nullable.t<string>
})