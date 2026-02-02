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
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>
}

@genType
@schema
type attributionExecutiveSummaryResponseSchema = {
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>
}

@genType
@schema
type cFOExecutiveSummaryResponseSchema = {
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
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
  impressions_what_if: @s.null option<float>,
  clicks_what_if: @s.null option<float>,
  orders_what_if: @s.null option<float>,
  units_sold_what_if: @s.null option<float>,
  sales_what_if: @s.null option<float>,
  ad_spend_what_if: @s.null option<float>,
  ad_impressions_what_if: @s.null option<float>,
  ad_clicks_what_if: @s.null option<float>,
  ad_orders_what_if: @s.null option<float>,
  ad_sales_what_if: @s.null option<float>,
  ad_units_sold_what_if: @s.null option<float>,
  ad_ctr_what_if: @s.null option<float>,
  ad_cvr_what_if: @s.null option<float>,
  cpc_what_if: @s.null option<float>,
  cpm_what_if: @s.null option<float>,
  organic_impressions_what_if: @s.null option<float>,
  organic_clicks_what_if: @s.null option<float>,
  organic_orders_what_if: @s.null option<float>,
  organic_sales_what_if: @s.null option<float>,
  organic_units_sold_what_if: @s.null option<float>,
  total_sales_what_if: @s.null option<float>,
  total_spend_what_if: @s.null option<float>,
  total_impressions_what_if: @s.null option<float>,
  total_clicks_what_if: @s.null option<float>,
  total_orders_what_if: @s.null option<float>,
  total_units_sold_what_if: @s.null option<float>,
  lost_sales_what_if: @s.null option<float>,
  ctr_what_if: @s.null option<float>,
  cvr_what_if: @s.null option<float>,
  acos_what_if: @s.null option<float>,
  tacos_what_if: @s.null option<float>,
  roas_what_if: @s.null option<float>,
  mer_what_if: @s.null option<float>,
  aov_what_if: @s.null option<float>,
  gross_profit_what_if: @s.null option<float>,
  gross_margin_what_if: @s.null option<float>,
  contribution_profit_what_if: @s.null option<float>,
  contribution_margin_what_if: @s.null option<float>,
  net_profit_what_if: @s.null option<float>,
  net_margin_what_if: @s.null option<float>,
  roi_what_if: @s.null option<float>,
  available_capital_what_if: @s.null option<float>,
  frozen_capital_what_if: @s.null option<float>,
  ebitda_what_if: @s.null option<float>,
  cogs_what_if: @s.null option<float>,
  cost_of_goods_sold_what_if: @s.null option<float>,
  amazon_fees_what_if: @s.null option<float>,
  opex_what_if: @s.null option<float>,
  discount_what_if: @s.null option<float>,
  coupon_what_if: @s.null option<float>,
  subscribe_save_what_if: @s.null option<float>,
  text_score_what_if: @s.null option<float>,
  image_score_what_if: @s.null option<float>,
  video_score_what_if: @s.null option<float>,
  a_plus_score_what_if: @s.null option<float>,
  fba_in_stock_rate_what_if: @s.null option<float>,
  inventory_turnover_what_if: @s.null option<float>,
  safety_stock_what_if: @s.null option<float>,
  storage_costs_what_if: @s.null option<float>,
  shipping_costs_what_if: @s.null option<float>,
  market_total_sales_what_if: @s.null option<float>,
  brand_market_share_what_if: @s.null option<float>,
  market_average_price_what_if: @s.null option<float>,
  attribution_sales_what_if: @s.null option<float>,
  attribution_spend_what_if: @s.null option<float>,
  attribution_impressions_what_if: @s.null option<float>,
  attribution_clicks_what_if: @s.null option<float>,
  attribution_orders_what_if: @s.null option<float>,
  attribution_units_sold_what_if: @s.null option<float>,
  attribution_ctr_what_if: @s.null option<float>,
  attribution_cvr_what_if: @s.null option<float>,
  attribution_acos_what_if: @s.null option<float>,
  attribution_roas_what_if: @s.null option<float>,
  attribution_cpc_what_if: @s.null option<float>,
  attribution_cpm_what_if: @s.null option<float>
}

@genType
@schema
type insightResponse = {
  summary: string,
  date_start: string,
  date_end: string,
  asin: @s.null option<string>,
  agent: string
}

@genType
@schema
type inventoryExecutiveSummaryResponseSchema = {
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryResponseSchema = {
  market_total_sales: @s.null option<float>,
  brand_market_share: @s.null option<float>,
  market_average_price: @s.null option<float>,
  market_total_units_sold: @s.null option<float>,
  market_asin_count: @s.null option<int>,
  market_promotion_value: @s.null option<float>,
  market_promotion_count: @s.null option<int>,
  market_review_score: @s.null option<float>,
  market_pos: @s.null option<float>,
  market_ad_spend: @s.null option<float>
}

@genType
@schema
type organicExecutiveSummaryResponseSchema = {
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
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
  total_sales_diff_pct: @s.null option<float>,
  net_profit_diff_pct: @s.null option<float>,
  gross_profit_diff_pct: @s.null option<float>,
  roi_diff_pct: @s.null option<float>,
  goals: option<array<Dict.t<string>>>,
  asin: @s.null option<string>
}

@genType
@schema
type totalExecutiveSummaryResponseSchema = {
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>
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
  current_value: @s.null option<float>,
  percentage_change: float,
  target_value: @s.null option<float>
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
  compare_value: @s.null option<Dict.t<string>>,
  compare_diff: @s.null option<Dict.t<string>>,
  compare_percent_diff: @s.null option<floatOrDict>
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
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>,
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
  compare_value: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: @s.null option<adsExecutiveSummaryResponseSchema>,
  diff: @s.null option<adsExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type attributionExecutiveSummaryWithForecastBreakdown = {
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>,
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
  compare_value: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: @s.null option<attributionExecutiveSummaryResponseSchema>,
  diff: @s.null option<attributionExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type cFOExecutiveSummaryWithForecastBreakdown = {
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
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
  compare_value: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: @s.null option<cFOExecutiveSummaryResponseSchema>,
  diff: @s.null option<cFOExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type tierLevelForecastParams = {
  impressions_what_if: @s.null option<float>,
  clicks_what_if: @s.null option<float>,
  orders_what_if: @s.null option<float>,
  units_sold_what_if: @s.null option<float>,
  sales_what_if: @s.null option<float>,
  ad_spend_what_if: @s.null option<float>,
  ad_impressions_what_if: @s.null option<float>,
  ad_clicks_what_if: @s.null option<float>,
  ad_orders_what_if: @s.null option<float>,
  ad_sales_what_if: @s.null option<float>,
  ad_units_sold_what_if: @s.null option<float>,
  ad_ctr_what_if: @s.null option<float>,
  ad_cvr_what_if: @s.null option<float>,
  cpc_what_if: @s.null option<float>,
  cpm_what_if: @s.null option<float>,
  organic_impressions_what_if: @s.null option<float>,
  organic_clicks_what_if: @s.null option<float>,
  organic_orders_what_if: @s.null option<float>,
  organic_sales_what_if: @s.null option<float>,
  organic_units_sold_what_if: @s.null option<float>,
  total_sales_what_if: @s.null option<float>,
  total_spend_what_if: @s.null option<float>,
  total_impressions_what_if: @s.null option<float>,
  total_clicks_what_if: @s.null option<float>,
  total_orders_what_if: @s.null option<float>,
  total_units_sold_what_if: @s.null option<float>,
  lost_sales_what_if: @s.null option<float>,
  ctr_what_if: @s.null option<float>,
  cvr_what_if: @s.null option<float>,
  acos_what_if: @s.null option<float>,
  tacos_what_if: @s.null option<float>,
  roas_what_if: @s.null option<float>,
  mer_what_if: @s.null option<float>,
  aov_what_if: @s.null option<float>,
  gross_profit_what_if: @s.null option<float>,
  gross_margin_what_if: @s.null option<float>,
  contribution_profit_what_if: @s.null option<float>,
  contribution_margin_what_if: @s.null option<float>,
  net_profit_what_if: @s.null option<float>,
  net_margin_what_if: @s.null option<float>,
  roi_what_if: @s.null option<float>,
  available_capital_what_if: @s.null option<float>,
  frozen_capital_what_if: @s.null option<float>,
  ebitda_what_if: @s.null option<float>,
  cogs_what_if: @s.null option<float>,
  cost_of_goods_sold_what_if: @s.null option<float>,
  amazon_fees_what_if: @s.null option<float>,
  opex_what_if: @s.null option<float>,
  discount_what_if: @s.null option<float>,
  coupon_what_if: @s.null option<float>,
  subscribe_save_what_if: @s.null option<float>,
  text_score_what_if: @s.null option<float>,
  image_score_what_if: @s.null option<float>,
  video_score_what_if: @s.null option<float>,
  a_plus_score_what_if: @s.null option<float>,
  fba_in_stock_rate_what_if: @s.null option<float>,
  inventory_turnover_what_if: @s.null option<float>,
  safety_stock_what_if: @s.null option<float>,
  storage_costs_what_if: @s.null option<float>,
  shipping_costs_what_if: @s.null option<float>,
  market_total_sales_what_if: @s.null option<float>,
  brand_market_share_what_if: @s.null option<float>,
  market_average_price_what_if: @s.null option<float>,
  attribution_sales_what_if: @s.null option<float>,
  attribution_spend_what_if: @s.null option<float>,
  attribution_impressions_what_if: @s.null option<float>,
  attribution_clicks_what_if: @s.null option<float>,
  attribution_orders_what_if: @s.null option<float>,
  attribution_units_sold_what_if: @s.null option<float>,
  attribution_ctr_what_if: @s.null option<float>,
  attribution_cvr_what_if: @s.null option<float>,
  attribution_acos_what_if: @s.null option<float>,
  attribution_roas_what_if: @s.null option<float>,
  attribution_cpc_what_if: @s.null option<float>,
  attribution_cpm_what_if: @s.null option<float>,
  no_sales: @s.null option<forecastParams>,
  poor: @s.null option<forecastParams>,
  mid: @s.null option<forecastParams>,
  good: @s.null option<forecastParams>
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
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>,
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
  compare_value: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  diff: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  market_total_sales: @s.null option<float>,
  brand_market_share: @s.null option<float>,
  market_average_price: @s.null option<float>,
  market_total_units_sold: @s.null option<float>,
  market_asin_count: @s.null option<int>,
  market_promotion_value: @s.null option<float>,
  market_promotion_count: @s.null option<int>,
  market_review_score: @s.null option<float>,
  market_pos: @s.null option<float>,
  market_ad_spend: @s.null option<float>,
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
  compare_value: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  diff: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type organicExecutiveSummaryWithForecastBreakdown = {
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
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
  projected: @s.null option<organicExecutiveSummaryResponseSchema>,
  diff: @s.null option<organicExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<organicExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
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
  compare_value: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
}

@genType
@schema
type totalExecutiveSummaryWithForecastBreakdown = {
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>,
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
  projected: @s.null option<totalExecutiveSummaryResponseSchema>,
  diff: @s.null option<totalExecutiveSummaryResponseSchema>,
  percent_diff: @s.null option<floatOrDict>,
  compare_value: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
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
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}

@genType
@schema
type timelineResponse_dict_ = {
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
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
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}

@genType
@schema
type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
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
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: @s.null option<Dict.t<string>>,
  compare_diff: @s.null option<Dict.t<string>>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
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
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: @s.null option<Dict.t<string>>,
  compare_diff: @s.null option<Dict.t<string>>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null option<float>,
  ad_clicks: float,
  ad_cvr: @s.null option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null option<float>,
  roas: @s.null option<float>,
  cpc: @s.null option<float>,
  cpm: @s.null option<float>,
  time_in_budget: @s.null option<float>,
  ad_tos_is: @s.null option<float>,
  ads_non_optimal_spend: @s.null option<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type getV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null option<float>,
  attribution_spend: @s.null option<float>,
  attribution_impressions: @s.null option<float>,
  attribution_ctr: @s.null option<float>,
  attribution_clicks: @s.null option<float>,
  attribution_cvr: @s.null option<float>,
  attribution_orders: @s.null option<float>,
  attribution_units_sold: @s.null option<float>,
  attribution_acos: @s.null option<float>,
  attribution_roas: @s.null option<float>,
  attribution_cpc: @s.null option<float>,
  attribution_cpm: @s.null option<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type getV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null option<float>,
  frozen_capital: @s.null option<float>,
  borrowed_capital: @s.null option<float>,
  gross_profit: @s.null option<float>,
  gross_margin: @s.null option<float>,
  contribution_profit: @s.null option<float>,
  contribution_margin: @s.null option<float>,
  net_profit: @s.null option<float>,
  net_margin: @s.null option<float>,
  opex: @s.null option<float>,
  roi: @s.null option<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type getV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null option<float>,
  fbt_in_stock_rate: @s.null option<float>,
  three_pl_in_stock_rate: @s.null option<float>,
  storage_costs: @s.null option<float>,
  shipping_costs: @s.null option<float>,
  forecasting_accuracy: @s.null option<float>,
  inventory_turnover: @s.null option<float>,
  safety_stock: @s.null option<float>,
  doi_available: @s.null option<float>,
  total_doi: @s.null option<float>,
  estimated_stock_out_date: @s.null option<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type getV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null option<float>,
  brand_market_share: @s.null option<float>,
  market_average_price: @s.null option<float>,
  market_total_units_sold: @s.null option<float>,
  market_asin_count: @s.null option<int>,
  market_promotion_value: @s.null option<float>,
  market_promotion_count: @s.null option<int>,
  market_review_score: @s.null option<float>,
  market_pos: @s.null option<float>,
  market_ad_spend: @s.null option<float>
}) | TimelineResponse({
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null option<float>,
  brand_market_share: @s.null option<float>,
  market_average_price: @s.null option<float>,
  market_total_units_sold: @s.null option<float>,
  market_asin_count: @s.null option<int>,
  market_promotion_value: @s.null option<float>,
  market_promotion_count: @s.null option<int>,
  market_review_score: @s.null option<float>,
  market_pos: @s.null option<float>,
  market_ad_spend: @s.null option<float>
}) | MarketIntelligenceExecutiveSummaryWithForecastBreakdown({
  market_total_sales: @s.null option<float>,
  brand_market_share: @s.null option<float>,
  market_average_price: @s.null option<float>,
  market_total_units_sold: @s.null option<float>,
  market_asin_count: @s.null option<int>,
  market_promotion_value: @s.null option<float>,
  market_promotion_count: @s.null option<int>,
  market_review_score: @s.null option<float>,
  market_pos: @s.null option<float>,
  market_ad_spend: @s.null option<float>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type postV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: @s.null option<float>,
  organic_ctr: @s.null option<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})

@genType
@tag("_tag")
@schema
type getV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null option<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null option<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null option<float>,
  total_spend: @s.null option<float>,
  total_impressions: @s.null option<float>,
  ctr: @s.null option<float>,
  total_clicks: @s.null option<float>,
  cvr: @s.null option<float>,
  total_orders: @s.null option<float>,
  total_units_sold: @s.null option<float>,
  total_ntb_orders: @s.null option<float>,
  tacos: @s.null option<float>,
  mer: @s.null option<float>,
  lost_sales: @s.null option<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null option<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null option<string>
})