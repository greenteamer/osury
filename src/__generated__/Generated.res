module S = Sury

@genType
@tag("_tag")
@schema
type floatOrDict = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@unboxed
@schema
type stringOrInt = String(string) | Int(int)

@genType
@schema
type adsExecutiveSummaryResponseSchema = {
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>
}

@genType
@schema
type attributionExecutiveSummaryResponseSchema = {
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>
}

@genType
@schema
type cFOExecutiveSummaryResponseSchema = {
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}

@genType
@schema
type dailyInventoryMetrics = {
  date: string,
  available_stock: float,
  in_transit: float,
  receiving: float,
  safety_stock: float,
  total_available: float,
  total_units_sold_30d: float,
  doi_available: float,
  total_doi: float
}

@genType
@schema
type forecastParams = {
  impressions_what_if: Nullable.t<float>,
  clicks_what_if: Nullable.t<float>,
  orders_what_if: Nullable.t<float>,
  units_sold_what_if: Nullable.t<float>,
  sales_what_if: Nullable.t<float>,
  ad_spend_what_if: Nullable.t<float>,
  ad_impressions_what_if: Nullable.t<float>,
  ad_clicks_what_if: Nullable.t<float>,
  ad_orders_what_if: Nullable.t<float>,
  ad_sales_what_if: Nullable.t<float>,
  ad_units_sold_what_if: Nullable.t<float>,
  ad_ctr_what_if: Nullable.t<float>,
  ad_cvr_what_if: Nullable.t<float>,
  cpc_what_if: Nullable.t<float>,
  cpm_what_if: Nullable.t<float>,
  organic_impressions_what_if: Nullable.t<float>,
  organic_clicks_what_if: Nullable.t<float>,
  organic_orders_what_if: Nullable.t<float>,
  organic_sales_what_if: Nullable.t<float>,
  organic_units_sold_what_if: Nullable.t<float>,
  total_sales_what_if: Nullable.t<float>,
  total_spend_what_if: Nullable.t<float>,
  total_impressions_what_if: Nullable.t<float>,
  total_clicks_what_if: Nullable.t<float>,
  total_orders_what_if: Nullable.t<float>,
  total_units_sold_what_if: Nullable.t<float>,
  lost_sales_what_if: Nullable.t<float>,
  ctr_what_if: Nullable.t<float>,
  cvr_what_if: Nullable.t<float>,
  acos_what_if: Nullable.t<float>,
  tacos_what_if: Nullable.t<float>,
  roas_what_if: Nullable.t<float>,
  mer_what_if: Nullable.t<float>,
  aov_what_if: Nullable.t<float>,
  gross_profit_what_if: Nullable.t<float>,
  gross_margin_what_if: Nullable.t<float>,
  contribution_profit_what_if: Nullable.t<float>,
  contribution_margin_what_if: Nullable.t<float>,
  net_profit_what_if: Nullable.t<float>,
  net_margin_what_if: Nullable.t<float>,
  roi_what_if: Nullable.t<float>,
  available_capital_what_if: Nullable.t<float>,
  frozen_capital_what_if: Nullable.t<float>,
  ebitda_what_if: Nullable.t<float>,
  cogs_what_if: Nullable.t<float>,
  cost_of_goods_sold_what_if: Nullable.t<float>,
  amazon_fees_what_if: Nullable.t<float>,
  opex_what_if: Nullable.t<float>,
  discount_what_if: Nullable.t<float>,
  coupon_what_if: Nullable.t<float>,
  subscribe_save_what_if: Nullable.t<float>,
  text_score_what_if: Nullable.t<float>,
  image_score_what_if: Nullable.t<float>,
  video_score_what_if: Nullable.t<float>,
  a_plus_score_what_if: Nullable.t<float>,
  fba_in_stock_rate_what_if: Nullable.t<float>,
  inventory_turnover_what_if: Nullable.t<float>,
  safety_stock_what_if: Nullable.t<float>,
  storage_costs_what_if: Nullable.t<float>,
  shipping_costs_what_if: Nullable.t<float>,
  market_total_sales_what_if: Nullable.t<float>,
  brand_market_share_what_if: Nullable.t<float>,
  market_average_price_what_if: Nullable.t<float>,
  attribution_sales_what_if: Nullable.t<float>,
  attribution_spend_what_if: Nullable.t<float>,
  attribution_impressions_what_if: Nullable.t<float>,
  attribution_clicks_what_if: Nullable.t<float>,
  attribution_orders_what_if: Nullable.t<float>,
  attribution_units_sold_what_if: Nullable.t<float>,
  attribution_ctr_what_if: Nullable.t<float>,
  attribution_cvr_what_if: Nullable.t<float>,
  attribution_acos_what_if: Nullable.t<float>,
  attribution_roas_what_if: Nullable.t<float>,
  attribution_cpc_what_if: Nullable.t<float>,
  attribution_cpm_what_if: Nullable.t<float>
}

@genType
@schema
type insightResponse = {
  summary: string,
  date_start: string,
  date_end: string,
  asin: Nullable.t<string>,
  agent: string
}

@genType
@schema
type inventoryExecutiveSummaryResponseSchema = {
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryResponseSchema = {
  market_total_sales: Nullable.t<float>,
  brand_market_share: Nullable.t<float>,
  market_average_price: Nullable.t<float>,
  market_total_units_sold: Nullable.t<float>,
  market_asin_count: Nullable.t<int>,
  market_promotion_value: Nullable.t<float>,
  market_promotion_count: Nullable.t<int>,
  market_review_score: Nullable.t<float>,
  market_pos: Nullable.t<float>,
  market_ad_spend: Nullable.t<float>
}

@genType
@schema
type organicExecutiveSummaryResponseSchema = {
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}

@genType
@schema
type strategicPlanResponse = {
  plan: string,
  forecast_period: string,
  projected_total_sales: float,
  projected_net_profit: float,
  projected_gross_profit: float,
  projected_roi: float,
  total_sales_diff_pct: Nullable.t<float>,
  net_profit_diff_pct: Nullable.t<float>,
  gross_profit_diff_pct: Nullable.t<float>,
  roi_diff_pct: Nullable.t<float>,
  goals: option<array<Dict.t<string>>>,
  asin: Nullable.t<string>
}

@genType
@schema
type totalExecutiveSummaryResponseSchema = {
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>
}

@genType
@schema
type totalInventoryMetrics = {
  available_stock: float,
  in_transit: float,
  receiving: float,
  safety_stock: float,
  total_available: float,
  total_units_sold_30d: float,
  doi_available: float,
  total_doi: float
}

@genType
@schema
type whatifAppliedEntry = {
  current_value: Nullable.t<float>,
  percentage_change: float,
  target_value: Nullable.t<float>
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
type timelineDataPoint_dict_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: Nullable.t<Dict.t<string>>,
  compare_diff: Nullable.t<Dict.t<string>>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type validationError = {
  loc: array<stringOrInt>,
  msg: string,
  @as("type") type_: string
}

@genType
@schema
type adsExecutiveSummaryWithForecastBreakdown = {
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>,
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
  compare_value: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: Nullable.t<adsExecutiveSummaryResponseSchema>,
  diff: Nullable.t<adsExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type attributionExecutiveSummaryWithForecastBreakdown = {
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>,
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
  compare_value: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  diff: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type cFOExecutiveSummaryWithForecastBreakdown = {
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
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
  compare_value: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  diff: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type tierLevelForecastParams = {
  impressions_what_if: Nullable.t<float>,
  clicks_what_if: Nullable.t<float>,
  orders_what_if: Nullable.t<float>,
  units_sold_what_if: Nullable.t<float>,
  sales_what_if: Nullable.t<float>,
  ad_spend_what_if: Nullable.t<float>,
  ad_impressions_what_if: Nullable.t<float>,
  ad_clicks_what_if: Nullable.t<float>,
  ad_orders_what_if: Nullable.t<float>,
  ad_sales_what_if: Nullable.t<float>,
  ad_units_sold_what_if: Nullable.t<float>,
  ad_ctr_what_if: Nullable.t<float>,
  ad_cvr_what_if: Nullable.t<float>,
  cpc_what_if: Nullable.t<float>,
  cpm_what_if: Nullable.t<float>,
  organic_impressions_what_if: Nullable.t<float>,
  organic_clicks_what_if: Nullable.t<float>,
  organic_orders_what_if: Nullable.t<float>,
  organic_sales_what_if: Nullable.t<float>,
  organic_units_sold_what_if: Nullable.t<float>,
  total_sales_what_if: Nullable.t<float>,
  total_spend_what_if: Nullable.t<float>,
  total_impressions_what_if: Nullable.t<float>,
  total_clicks_what_if: Nullable.t<float>,
  total_orders_what_if: Nullable.t<float>,
  total_units_sold_what_if: Nullable.t<float>,
  lost_sales_what_if: Nullable.t<float>,
  ctr_what_if: Nullable.t<float>,
  cvr_what_if: Nullable.t<float>,
  acos_what_if: Nullable.t<float>,
  tacos_what_if: Nullable.t<float>,
  roas_what_if: Nullable.t<float>,
  mer_what_if: Nullable.t<float>,
  aov_what_if: Nullable.t<float>,
  gross_profit_what_if: Nullable.t<float>,
  gross_margin_what_if: Nullable.t<float>,
  contribution_profit_what_if: Nullable.t<float>,
  contribution_margin_what_if: Nullable.t<float>,
  net_profit_what_if: Nullable.t<float>,
  net_margin_what_if: Nullable.t<float>,
  roi_what_if: Nullable.t<float>,
  available_capital_what_if: Nullable.t<float>,
  frozen_capital_what_if: Nullable.t<float>,
  ebitda_what_if: Nullable.t<float>,
  cogs_what_if: Nullable.t<float>,
  cost_of_goods_sold_what_if: Nullable.t<float>,
  amazon_fees_what_if: Nullable.t<float>,
  opex_what_if: Nullable.t<float>,
  discount_what_if: Nullable.t<float>,
  coupon_what_if: Nullable.t<float>,
  subscribe_save_what_if: Nullable.t<float>,
  text_score_what_if: Nullable.t<float>,
  image_score_what_if: Nullable.t<float>,
  video_score_what_if: Nullable.t<float>,
  a_plus_score_what_if: Nullable.t<float>,
  fba_in_stock_rate_what_if: Nullable.t<float>,
  inventory_turnover_what_if: Nullable.t<float>,
  safety_stock_what_if: Nullable.t<float>,
  storage_costs_what_if: Nullable.t<float>,
  shipping_costs_what_if: Nullable.t<float>,
  market_total_sales_what_if: Nullable.t<float>,
  brand_market_share_what_if: Nullable.t<float>,
  market_average_price_what_if: Nullable.t<float>,
  attribution_sales_what_if: Nullable.t<float>,
  attribution_spend_what_if: Nullable.t<float>,
  attribution_impressions_what_if: Nullable.t<float>,
  attribution_clicks_what_if: Nullable.t<float>,
  attribution_orders_what_if: Nullable.t<float>,
  attribution_units_sold_what_if: Nullable.t<float>,
  attribution_ctr_what_if: Nullable.t<float>,
  attribution_cvr_what_if: Nullable.t<float>,
  attribution_acos_what_if: Nullable.t<float>,
  attribution_roas_what_if: Nullable.t<float>,
  attribution_cpc_what_if: Nullable.t<float>,
  attribution_cpm_what_if: Nullable.t<float>,
  no_sales: Nullable.t<forecastParams>,
  poor: Nullable.t<forecastParams>,
  mid: Nullable.t<forecastParams>,
  good: Nullable.t<forecastParams>
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
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>,
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
  compare_value: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  diff: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  market_total_sales: Nullable.t<float>,
  brand_market_share: Nullable.t<float>,
  market_average_price: Nullable.t<float>,
  market_total_units_sold: Nullable.t<float>,
  market_asin_count: Nullable.t<int>,
  market_promotion_value: Nullable.t<float>,
  market_promotion_count: Nullable.t<int>,
  market_review_score: Nullable.t<float>,
  market_pos: Nullable.t<float>,
  market_ad_spend: Nullable.t<float>,
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
  compare_value: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  diff: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type organicExecutiveSummaryWithForecastBreakdown = {
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}

@genType
@schema
type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: organicExecutiveSummaryResponseSchema,
  projected: Nullable.t<organicExecutiveSummaryResponseSchema>,
  diff: Nullable.t<organicExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type getV1MathInsightsStrategicPlanResponse = strategicPlanResponse

@genType
@schema
type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type totalExecutiveSummaryWithForecastBreakdown = {
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>,
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
  projected: Nullable.t<totalExecutiveSummaryResponseSchema>,
  diff: Nullable.t<totalExecutiveSummaryResponseSchema>,
  percent_diff: Nullable.t<floatOrDict>,
  compare_value: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
}

@genType
@schema
type inventoryMetricsResponse = {
  daily_metrics: array<dailyInventoryMetrics>,
  total_metrics: totalInventoryMetrics
}

@genType
@schema
type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}

@genType
@schema
type timelineResponse_dict_ = {
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
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
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@schema
type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}

@genType
@tag("_tag")
@schema
type getV1MathInventoryMetricsResponse = InventoryMetricsResponse({
  daily_metrics: array<dailyInventoryMetrics>,
  total_metrics: totalInventoryMetrics
}) | TimelineResponse({
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: Nullable.t<Dict.t<string>>,
  compare_diff: Nullable.t<Dict.t<string>>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: Nullable.t<Dict.t<string>>,
  compare_diff: Nullable.t<Dict.t<string>>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: Nullable.t<float>,
  ad_clicks: float,
  ad_cvr: Nullable.t<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: Nullable.t<float>,
  roas: Nullable.t<float>,
  cpc: Nullable.t<float>,
  cpm: Nullable.t<float>,
  time_in_budget: Nullable.t<float>,
  ad_tos_is: Nullable.t<float>,
  ads_non_optimal_spend: Nullable.t<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: Nullable.t<float>,
  attribution_spend: Nullable.t<float>,
  attribution_impressions: Nullable.t<float>,
  attribution_ctr: Nullable.t<float>,
  attribution_clicks: Nullable.t<float>,
  attribution_cvr: Nullable.t<float>,
  attribution_orders: Nullable.t<float>,
  attribution_units_sold: Nullable.t<float>,
  attribution_acos: Nullable.t<float>,
  attribution_roas: Nullable.t<float>,
  attribution_cpc: Nullable.t<float>,
  attribution_cpm: Nullable.t<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: Nullable.t<float>,
  frozen_capital: Nullable.t<float>,
  borrowed_capital: Nullable.t<float>,
  gross_profit: Nullable.t<float>,
  gross_margin: Nullable.t<float>,
  contribution_profit: Nullable.t<float>,
  contribution_margin: Nullable.t<float>,
  net_profit: Nullable.t<float>,
  net_margin: Nullable.t<float>,
  opex: Nullable.t<float>,
  roi: Nullable.t<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: Nullable.t<float>,
  fbt_in_stock_rate: Nullable.t<float>,
  three_pl_in_stock_rate: Nullable.t<float>,
  storage_costs: Nullable.t<float>,
  shipping_costs: Nullable.t<float>,
  forecasting_accuracy: Nullable.t<float>,
  inventory_turnover: Nullable.t<float>,
  safety_stock: Nullable.t<float>,
  doi_available: Nullable.t<float>,
  total_doi: Nullable.t<float>,
  estimated_stock_out_date: Nullable.t<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: Nullable.t<float>,
  brand_market_share: Nullable.t<float>,
  market_average_price: Nullable.t<float>,
  market_total_units_sold: Nullable.t<float>,
  market_asin_count: Nullable.t<int>,
  market_promotion_value: Nullable.t<float>,
  market_promotion_count: Nullable.t<int>,
  market_review_score: Nullable.t<float>,
  market_pos: Nullable.t<float>,
  market_ad_spend: Nullable.t<float>
}) | TimelineResponse({
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: Nullable.t<float>,
  brand_market_share: Nullable.t<float>,
  market_average_price: Nullable.t<float>,
  market_total_units_sold: Nullable.t<float>,
  market_asin_count: Nullable.t<int>,
  market_promotion_value: Nullable.t<float>,
  market_promotion_count: Nullable.t<int>,
  market_review_score: Nullable.t<float>,
  market_pos: Nullable.t<float>,
  market_ad_spend: Nullable.t<float>
}) | MarketIntelligenceExecutiveSummaryWithForecastBreakdown({
  market_total_sales: Nullable.t<float>,
  brand_market_share: Nullable.t<float>,
  market_average_price: Nullable.t<float>,
  market_total_units_sold: Nullable.t<float>,
  market_asin_count: Nullable.t<int>,
  market_promotion_value: Nullable.t<float>,
  market_promotion_count: Nullable.t<int>,
  market_review_score: Nullable.t<float>,
  market_pos: Nullable.t<float>,
  market_ad_spend: Nullable.t<float>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type postV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: Nullable.t<float>,
  organic_ctr: Nullable.t<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})

@genType
@tag("_tag")
@schema
type getV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_diff: Nullable.t<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: Nullable.t<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: Nullable.t<float>,
  total_spend: Nullable.t<float>,
  total_impressions: Nullable.t<float>,
  ctr: Nullable.t<float>,
  total_clicks: Nullable.t<float>,
  cvr: Nullable.t<float>,
  total_orders: Nullable.t<float>,
  total_units_sold: Nullable.t<float>,
  total_ntb_orders: Nullable.t<float>,
  tacos: Nullable.t<float>,
  mer: Nullable.t<float>,
  lost_sales: Nullable.t<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<Nullable.t<float>>,
  percent_diff: Dict.t<Nullable.t<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: Nullable.t<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: Nullable.t<string>
})