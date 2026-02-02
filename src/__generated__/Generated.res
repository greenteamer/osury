@genType.import(("./Null.gen.ts", "t"))
type null<'a> = option<'a>

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
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>
}

@genType
@schema
type attributionExecutiveSummaryResponseSchema = {
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>
}

@genType
@schema
type cFOExecutiveSummaryResponseSchema = {
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
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
  impressions_what_if: @s.null null<float>,
  clicks_what_if: @s.null null<float>,
  orders_what_if: @s.null null<float>,
  units_sold_what_if: @s.null null<float>,
  sales_what_if: @s.null null<float>,
  ad_spend_what_if: @s.null null<float>,
  ad_impressions_what_if: @s.null null<float>,
  ad_clicks_what_if: @s.null null<float>,
  ad_orders_what_if: @s.null null<float>,
  ad_sales_what_if: @s.null null<float>,
  ad_units_sold_what_if: @s.null null<float>,
  ad_ctr_what_if: @s.null null<float>,
  ad_cvr_what_if: @s.null null<float>,
  cpc_what_if: @s.null null<float>,
  cpm_what_if: @s.null null<float>,
  organic_impressions_what_if: @s.null null<float>,
  organic_clicks_what_if: @s.null null<float>,
  organic_orders_what_if: @s.null null<float>,
  organic_sales_what_if: @s.null null<float>,
  organic_units_sold_what_if: @s.null null<float>,
  total_sales_what_if: @s.null null<float>,
  total_spend_what_if: @s.null null<float>,
  total_impressions_what_if: @s.null null<float>,
  total_clicks_what_if: @s.null null<float>,
  total_orders_what_if: @s.null null<float>,
  total_units_sold_what_if: @s.null null<float>,
  lost_sales_what_if: @s.null null<float>,
  ctr_what_if: @s.null null<float>,
  cvr_what_if: @s.null null<float>,
  acos_what_if: @s.null null<float>,
  tacos_what_if: @s.null null<float>,
  roas_what_if: @s.null null<float>,
  mer_what_if: @s.null null<float>,
  aov_what_if: @s.null null<float>,
  gross_profit_what_if: @s.null null<float>,
  gross_margin_what_if: @s.null null<float>,
  contribution_profit_what_if: @s.null null<float>,
  contribution_margin_what_if: @s.null null<float>,
  net_profit_what_if: @s.null null<float>,
  net_margin_what_if: @s.null null<float>,
  roi_what_if: @s.null null<float>,
  available_capital_what_if: @s.null null<float>,
  frozen_capital_what_if: @s.null null<float>,
  ebitda_what_if: @s.null null<float>,
  cogs_what_if: @s.null null<float>,
  cost_of_goods_sold_what_if: @s.null null<float>,
  amazon_fees_what_if: @s.null null<float>,
  opex_what_if: @s.null null<float>,
  discount_what_if: @s.null null<float>,
  coupon_what_if: @s.null null<float>,
  subscribe_save_what_if: @s.null null<float>,
  text_score_what_if: @s.null null<float>,
  image_score_what_if: @s.null null<float>,
  video_score_what_if: @s.null null<float>,
  a_plus_score_what_if: @s.null null<float>,
  fba_in_stock_rate_what_if: @s.null null<float>,
  inventory_turnover_what_if: @s.null null<float>,
  safety_stock_what_if: @s.null null<float>,
  storage_costs_what_if: @s.null null<float>,
  shipping_costs_what_if: @s.null null<float>,
  market_total_sales_what_if: @s.null null<float>,
  brand_market_share_what_if: @s.null null<float>,
  market_average_price_what_if: @s.null null<float>,
  attribution_sales_what_if: @s.null null<float>,
  attribution_spend_what_if: @s.null null<float>,
  attribution_impressions_what_if: @s.null null<float>,
  attribution_clicks_what_if: @s.null null<float>,
  attribution_orders_what_if: @s.null null<float>,
  attribution_units_sold_what_if: @s.null null<float>,
  attribution_ctr_what_if: @s.null null<float>,
  attribution_cvr_what_if: @s.null null<float>,
  attribution_acos_what_if: @s.null null<float>,
  attribution_roas_what_if: @s.null null<float>,
  attribution_cpc_what_if: @s.null null<float>,
  attribution_cpm_what_if: @s.null null<float>
}

@genType
@schema
type insightResponse = {
  summary: string,
  date_start: string,
  date_end: string,
  asin: @s.null null<string>,
  agent: string
}

@genType
@schema
type inventoryExecutiveSummaryResponseSchema = {
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryResponseSchema = {
  market_total_sales: @s.null null<float>,
  brand_market_share: @s.null null<float>,
  market_average_price: @s.null null<float>,
  market_total_units_sold: @s.null null<float>,
  market_asin_count: @s.null null<int>,
  market_promotion_value: @s.null null<float>,
  market_promotion_count: @s.null null<int>,
  market_review_score: @s.null null<float>,
  market_pos: @s.null null<float>,
  market_ad_spend: @s.null null<float>
}

@genType
@schema
type organicExecutiveSummaryResponseSchema = {
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
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
  total_sales_diff_pct: @s.null null<float>,
  net_profit_diff_pct: @s.null null<float>,
  gross_profit_diff_pct: @s.null null<float>,
  roi_diff_pct: @s.null null<float>,
  goals: option<array<Dict.t<string>>>,
  asin: @s.null null<string>
}

@genType
@schema
type totalExecutiveSummaryResponseSchema = {
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>
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
  current_value: @s.null null<float>,
  percentage_change: float,
  target_value: @s.null null<float>
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
  compare_value: @s.null null<Dict.t<string>>,
  compare_diff: @s.null null<Dict.t<string>>,
  compare_percent_diff: @s.null null<floatOrDict>
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
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>,
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
  compare_value: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: @s.null null<adsExecutiveSummaryResponseSchema>,
  diff: @s.null null<adsExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type attributionExecutiveSummaryWithForecastBreakdown = {
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>,
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
  compare_value: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: @s.null null<attributionExecutiveSummaryResponseSchema>,
  diff: @s.null null<attributionExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type cFOExecutiveSummaryWithForecastBreakdown = {
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
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
  compare_value: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: @s.null null<cFOExecutiveSummaryResponseSchema>,
  diff: @s.null null<cFOExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type tierLevelForecastParams = {
  impressions_what_if: @s.null null<float>,
  clicks_what_if: @s.null null<float>,
  orders_what_if: @s.null null<float>,
  units_sold_what_if: @s.null null<float>,
  sales_what_if: @s.null null<float>,
  ad_spend_what_if: @s.null null<float>,
  ad_impressions_what_if: @s.null null<float>,
  ad_clicks_what_if: @s.null null<float>,
  ad_orders_what_if: @s.null null<float>,
  ad_sales_what_if: @s.null null<float>,
  ad_units_sold_what_if: @s.null null<float>,
  ad_ctr_what_if: @s.null null<float>,
  ad_cvr_what_if: @s.null null<float>,
  cpc_what_if: @s.null null<float>,
  cpm_what_if: @s.null null<float>,
  organic_impressions_what_if: @s.null null<float>,
  organic_clicks_what_if: @s.null null<float>,
  organic_orders_what_if: @s.null null<float>,
  organic_sales_what_if: @s.null null<float>,
  organic_units_sold_what_if: @s.null null<float>,
  total_sales_what_if: @s.null null<float>,
  total_spend_what_if: @s.null null<float>,
  total_impressions_what_if: @s.null null<float>,
  total_clicks_what_if: @s.null null<float>,
  total_orders_what_if: @s.null null<float>,
  total_units_sold_what_if: @s.null null<float>,
  lost_sales_what_if: @s.null null<float>,
  ctr_what_if: @s.null null<float>,
  cvr_what_if: @s.null null<float>,
  acos_what_if: @s.null null<float>,
  tacos_what_if: @s.null null<float>,
  roas_what_if: @s.null null<float>,
  mer_what_if: @s.null null<float>,
  aov_what_if: @s.null null<float>,
  gross_profit_what_if: @s.null null<float>,
  gross_margin_what_if: @s.null null<float>,
  contribution_profit_what_if: @s.null null<float>,
  contribution_margin_what_if: @s.null null<float>,
  net_profit_what_if: @s.null null<float>,
  net_margin_what_if: @s.null null<float>,
  roi_what_if: @s.null null<float>,
  available_capital_what_if: @s.null null<float>,
  frozen_capital_what_if: @s.null null<float>,
  ebitda_what_if: @s.null null<float>,
  cogs_what_if: @s.null null<float>,
  cost_of_goods_sold_what_if: @s.null null<float>,
  amazon_fees_what_if: @s.null null<float>,
  opex_what_if: @s.null null<float>,
  discount_what_if: @s.null null<float>,
  coupon_what_if: @s.null null<float>,
  subscribe_save_what_if: @s.null null<float>,
  text_score_what_if: @s.null null<float>,
  image_score_what_if: @s.null null<float>,
  video_score_what_if: @s.null null<float>,
  a_plus_score_what_if: @s.null null<float>,
  fba_in_stock_rate_what_if: @s.null null<float>,
  inventory_turnover_what_if: @s.null null<float>,
  safety_stock_what_if: @s.null null<float>,
  storage_costs_what_if: @s.null null<float>,
  shipping_costs_what_if: @s.null null<float>,
  market_total_sales_what_if: @s.null null<float>,
  brand_market_share_what_if: @s.null null<float>,
  market_average_price_what_if: @s.null null<float>,
  attribution_sales_what_if: @s.null null<float>,
  attribution_spend_what_if: @s.null null<float>,
  attribution_impressions_what_if: @s.null null<float>,
  attribution_clicks_what_if: @s.null null<float>,
  attribution_orders_what_if: @s.null null<float>,
  attribution_units_sold_what_if: @s.null null<float>,
  attribution_ctr_what_if: @s.null null<float>,
  attribution_cvr_what_if: @s.null null<float>,
  attribution_acos_what_if: @s.null null<float>,
  attribution_roas_what_if: @s.null null<float>,
  attribution_cpc_what_if: @s.null null<float>,
  attribution_cpm_what_if: @s.null null<float>,
  no_sales: @s.null null<forecastParams>,
  poor: @s.null null<forecastParams>,
  mid: @s.null null<forecastParams>,
  good: @s.null null<forecastParams>
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
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>,
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
  compare_value: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  diff: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  market_total_sales: @s.null null<float>,
  brand_market_share: @s.null null<float>,
  market_average_price: @s.null null<float>,
  market_total_units_sold: @s.null null<float>,
  market_asin_count: @s.null null<int>,
  market_promotion_value: @s.null null<float>,
  market_promotion_count: @s.null null<int>,
  market_review_score: @s.null null<float>,
  market_pos: @s.null null<float>,
  market_ad_spend: @s.null null<float>,
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
  compare_value: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  diff: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type organicExecutiveSummaryWithForecastBreakdown = {
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
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
  projected: @s.null null<organicExecutiveSummaryResponseSchema>,
  diff: @s.null null<organicExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<organicExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
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
  compare_value: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
}

@genType
@schema
type totalExecutiveSummaryWithForecastBreakdown = {
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>,
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
  projected: @s.null null<totalExecutiveSummaryResponseSchema>,
  diff: @s.null null<totalExecutiveSummaryResponseSchema>,
  percent_diff: @s.null null<floatOrDict>,
  compare_value: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
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
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}

@genType
@schema
type timelineResponse_dict_ = {
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
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
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}

@genType
@schema
type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
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
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: @s.null null<Dict.t<string>>,
  compare_diff: @s.null null<Dict.t<string>>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
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
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: Dict.t<string>,
  compare_value: @s.null null<Dict.t<string>>,
  compare_diff: @s.null null<Dict.t<string>>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type getV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAdsExecutiveSummaryResponse = AdsExecutiveSummaryResponseSchema({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>
}) | AdsExecutiveSummaryWithForecastBreakdown({
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: @s.null null<float>,
  ad_clicks: float,
  ad_cvr: @s.null null<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: @s.null null<float>,
  roas: @s.null null<float>,
  cpc: @s.null null<float>,
  cpm: @s.null null<float>,
  time_in_budget: @s.null null<float>,
  ad_tos_is: @s.null null<float>,
  ads_non_optimal_spend: @s.null null<float>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type getV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathAttributionExecutiveSummaryResponse = AttributionExecutiveSummaryResponseSchema({
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>
}) | AttributionExecutiveSummaryWithForecastBreakdown({
  attribution_sales: @s.null null<float>,
  attribution_spend: @s.null null<float>,
  attribution_impressions: @s.null null<float>,
  attribution_ctr: @s.null null<float>,
  attribution_clicks: @s.null null<float>,
  attribution_cvr: @s.null null<float>,
  attribution_orders: @s.null null<float>,
  attribution_units_sold: @s.null null<float>,
  attribution_acos: @s.null null<float>,
  attribution_roas: @s.null null<float>,
  attribution_cpc: @s.null null<float>,
  attribution_cpm: @s.null null<float>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type getV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathCfoExecutiveSummaryResponse = CFOExecutiveSummaryResponseSchema({
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
  cost_of_goods_sold: float,
  amazon_fees: float
}) | CFOExecutiveSummaryWithForecastBreakdown({
  available_capital: @s.null null<float>,
  frozen_capital: @s.null null<float>,
  borrowed_capital: @s.null null<float>,
  gross_profit: @s.null null<float>,
  gross_margin: @s.null null<float>,
  contribution_profit: @s.null null<float>,
  contribution_margin: @s.null null<float>,
  net_profit: @s.null null<float>,
  net_margin: @s.null null<float>,
  opex: @s.null null<float>,
  roi: @s.null null<float>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type getV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathInventoryMetricsExecutiveSummaryResponse = InventoryExecutiveSummaryResponseSchema({
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>
}) | InventoryExecutiveSummaryWithForecastBreakdown({
  fba_in_stock_rate: @s.null null<float>,
  fbt_in_stock_rate: @s.null null<float>,
  three_pl_in_stock_rate: @s.null null<float>,
  storage_costs: @s.null null<float>,
  shipping_costs: @s.null null<float>,
  forecasting_accuracy: @s.null null<float>,
  inventory_turnover: @s.null null<float>,
  safety_stock: @s.null null<float>,
  doi_available: @s.null null<float>,
  total_doi: @s.null null<float>,
  estimated_stock_out_date: @s.null null<string>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type getV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null null<float>,
  brand_market_share: @s.null null<float>,
  market_average_price: @s.null null<float>,
  market_total_units_sold: @s.null null<float>,
  market_asin_count: @s.null null<int>,
  market_promotion_value: @s.null null<float>,
  market_promotion_count: @s.null null<int>,
  market_review_score: @s.null null<float>,
  market_pos: @s.null null<float>,
  market_ad_spend: @s.null null<float>
}) | TimelineResponse({
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathMarketIntelligenceExecutiveSummaryResponse = MarketIntelligenceExecutiveSummaryResponseSchema({
  market_total_sales: @s.null null<float>,
  brand_market_share: @s.null null<float>,
  market_average_price: @s.null null<float>,
  market_total_units_sold: @s.null null<float>,
  market_asin_count: @s.null null<int>,
  market_promotion_value: @s.null null<float>,
  market_promotion_count: @s.null null<int>,
  market_review_score: @s.null null<float>,
  market_pos: @s.null null<float>,
  market_ad_spend: @s.null null<float>
}) | MarketIntelligenceExecutiveSummaryWithForecastBreakdown({
  market_total_sales: @s.null null<float>,
  brand_market_share: @s.null null<float>,
  market_average_price: @s.null null<float>,
  market_total_units_sold: @s.null null<float>,
  market_asin_count: @s.null null<int>,
  market_promotion_value: @s.null null<float>,
  market_promotion_count: @s.null null<int>,
  market_review_score: @s.null null<float>,
  market_pos: @s.null null<float>,
  market_ad_spend: @s.null null<float>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type postV1MathOrganicExecutiveSummaryResponse = OrganicExecutiveSummaryResponseSchema({
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}) | OrganicExecutiveSummaryWithForecastBreakdown({
  organic_sales: float,
  organic_impressions: @s.null null<float>,
  organic_ctr: @s.null null<float>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})

@genType
@tag("_tag")
@schema
type getV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | TimelineResponse({
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
}) | TimelineDataPoint({
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_diff: @s.null null<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: @s.null null<floatOrDict>
})

@genType
@tag("_tag")
@schema
type postV1MathTotalExecutiveSummaryResponse = TotalExecutiveSummaryResponseSchema({
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>
}) | TotalExecutiveSummaryWithForecastBreakdown({
  total_sales: @s.null null<float>,
  total_spend: @s.null null<float>,
  total_impressions: @s.null null<float>,
  ctr: @s.null null<float>,
  total_clicks: @s.null null<float>,
  cvr: @s.null null<float>,
  total_orders: @s.null null<float>,
  total_units_sold: @s.null null<float>,
  total_ntb_orders: @s.null null<float>,
  tacos: @s.null null<float>,
  mer: @s.null null<float>,
  lost_sales: @s.null null<float>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}) | WhatifResponse({
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<null<float>>,
  percent_diff: Dict.t<null<float>>,
  whatif_applied: Dict.t<whatifAppliedEntry>,
  model_info: whatifModelInfo,
  warnings: @s.null null<array<string>>
}) | WhatifTimelineResponse({
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: @s.null null<string>
})