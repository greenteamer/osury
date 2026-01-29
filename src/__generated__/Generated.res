@genType
@tag("_tag")
@schema
type timelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type timelineDataPoint_dict__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type validationError_loc = String(string) | Int(int)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff = Float(float) | Dict(Dict.t<string>)

@genType
@schema
type adsExecutiveSummaryResponseSchema = {
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: option<float>,
  ad_clicks: float,
  ad_cvr: option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: option<float>,
  roas: option<float>,
  cpc: option<float>,
  cpm: option<float>,
  time_in_budget: option<float>,
  ad_tos_is: option<float>,
  ads_non_optimal_spend: option<float>
}

@genType
@schema
type attributionExecutiveSummaryResponseSchema = {
  attribution_sales: option<float>,
  attribution_spend: option<float>,
  attribution_impressions: option<float>,
  attribution_ctr: option<float>,
  attribution_clicks: option<float>,
  attribution_cvr: option<float>,
  attribution_orders: option<float>,
  attribution_units_sold: option<float>,
  attribution_acos: option<float>,
  attribution_roas: option<float>,
  attribution_cpc: option<float>,
  attribution_cpm: option<float>
}

@genType
@schema
type cFOExecutiveSummaryResponseSchema = {
  available_capital: option<float>,
  frozen_capital: option<float>,
  borrowed_capital: option<float>,
  gross_profit: option<float>,
  gross_margin: option<float>,
  contribution_profit: option<float>,
  contribution_margin: option<float>,
  net_profit: option<float>,
  net_margin: option<float>,
  opex: option<float>,
  roi: option<float>,
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
  impressions_what_if: option<float>,
  clicks_what_if: option<float>,
  orders_what_if: option<float>,
  units_sold_what_if: option<float>,
  sales_what_if: option<float>,
  ad_spend_what_if: option<float>,
  ad_impressions_what_if: option<float>,
  ad_clicks_what_if: option<float>,
  ad_orders_what_if: option<float>,
  ad_sales_what_if: option<float>,
  ad_units_sold_what_if: option<float>,
  ad_ctr_what_if: option<float>,
  ad_cvr_what_if: option<float>,
  cpc_what_if: option<float>,
  cpm_what_if: option<float>,
  organic_impressions_what_if: option<float>,
  organic_clicks_what_if: option<float>,
  organic_orders_what_if: option<float>,
  organic_sales_what_if: option<float>,
  organic_units_sold_what_if: option<float>,
  total_sales_what_if: option<float>,
  total_spend_what_if: option<float>,
  total_impressions_what_if: option<float>,
  total_clicks_what_if: option<float>,
  total_orders_what_if: option<float>,
  total_units_sold_what_if: option<float>,
  lost_sales_what_if: option<float>,
  ctr_what_if: option<float>,
  cvr_what_if: option<float>,
  acos_what_if: option<float>,
  tacos_what_if: option<float>,
  roas_what_if: option<float>,
  mer_what_if: option<float>,
  aov_what_if: option<float>,
  gross_profit_what_if: option<float>,
  gross_margin_what_if: option<float>,
  contribution_profit_what_if: option<float>,
  contribution_margin_what_if: option<float>,
  net_profit_what_if: option<float>,
  net_margin_what_if: option<float>,
  roi_what_if: option<float>,
  available_capital_what_if: option<float>,
  frozen_capital_what_if: option<float>,
  ebitda_what_if: option<float>,
  cogs_what_if: option<float>,
  cost_of_goods_sold_what_if: option<float>,
  amazon_fees_what_if: option<float>,
  opex_what_if: option<float>,
  discount_what_if: option<float>,
  coupon_what_if: option<float>,
  subscribe_save_what_if: option<float>,
  text_score_what_if: option<float>,
  image_score_what_if: option<float>,
  video_score_what_if: option<float>,
  a_plus_score_what_if: option<float>,
  fba_in_stock_rate_what_if: option<float>,
  inventory_turnover_what_if: option<float>,
  safety_stock_what_if: option<float>,
  storage_costs_what_if: option<float>,
  shipping_costs_what_if: option<float>,
  market_total_sales_what_if: option<float>,
  brand_market_share_what_if: option<float>,
  market_average_price_what_if: option<float>,
  attribution_sales_what_if: option<float>,
  attribution_spend_what_if: option<float>,
  attribution_impressions_what_if: option<float>,
  attribution_clicks_what_if: option<float>,
  attribution_orders_what_if: option<float>,
  attribution_units_sold_what_if: option<float>,
  attribution_ctr_what_if: option<float>,
  attribution_cvr_what_if: option<float>,
  attribution_acos_what_if: option<float>,
  attribution_roas_what_if: option<float>,
  attribution_cpc_what_if: option<float>,
  attribution_cpm_what_if: option<float>
}

@genType
@schema
type insightResponse = {
  summary: string,
  date_start: string,
  date_end: string,
  asin: option<string>,
  agent: string
}

@genType
@schema
type inventoryExecutiveSummaryResponseSchema = {
  fba_in_stock_rate: option<float>,
  fbt_in_stock_rate: option<float>,
  three_pl_in_stock_rate: option<float>,
  storage_costs: option<float>,
  shipping_costs: option<float>,
  forecasting_accuracy: option<float>,
  inventory_turnover: option<float>,
  safety_stock: option<float>,
  doi_available: option<float>,
  total_doi: option<float>,
  estimated_stock_out_date: option<string>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryResponseSchema = {
  market_total_sales: option<float>,
  brand_market_share: option<float>,
  market_average_price: option<float>,
  market_total_units_sold: option<float>,
  market_asin_count: option<int>,
  market_promotion_value: option<float>,
  market_promotion_count: option<int>,
  market_review_score: option<float>,
  market_pos: option<float>,
  market_ad_spend: option<float>
}

@genType
@schema
type organicExecutiveSummaryResponseSchema = {
  organic_sales: float,
  organic_impressions: option<float>,
  organic_ctr: option<float>,
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
  total_sales_diff_pct: option<float>,
  net_profit_diff_pct: option<float>,
  gross_profit_diff_pct: option<float>,
  roi_diff_pct: option<float>,
  goals: option<array<Dict.t<string>>>,
  asin: option<string>
}

@genType
@schema
type totalExecutiveSummaryResponseSchema = {
  total_sales: option<float>,
  total_spend: option<float>,
  total_impressions: option<float>,
  ctr: option<float>,
  total_clicks: option<float>,
  cvr: option<float>,
  total_orders: option<float>,
  total_units_sold: option<float>,
  total_ntb_orders: option<float>,
  tacos: option<float>,
  mer: option<float>,
  lost_sales: option<float>
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
  current_value: option<float>,
  percentage_change: float,
  target_value: option<float>
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
  compare_value: option<Dict.t<string>>,
  compare_diff: option<Dict.t<string>>,
  compare_percent_diff: option<timelineDataPoint_dict__compare_percent_diff>
}

@genType
@schema
type validationError = {
  loc: array<validationError_loc>,
  msg: string,
  @as("type") type_: string
}

@genType
@schema
type adsExecutiveSummaryWithForecastBreakdown = {
  ad_sales: float,
  ad_spend: float,
  ad_impressions: float,
  ad_ctr: option<float>,
  ad_clicks: float,
  ad_cvr: option<float>,
  ad_orders: float,
  ad_units_sold: float,
  acos: option<float>,
  roas: option<float>,
  cpc: option<float>,
  cpm: option<float>,
  time_in_budget: option<float>,
  ad_tos_is: option<float>,
  ads_non_optimal_spend: option<float>,
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
  compare_value: option<adsExecutiveSummaryResponseSchema>,
  compare_diff: option<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: option<adsExecutiveSummaryResponseSchema>,
  diff: option<adsExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<adsExecutiveSummaryResponseSchema>,
  compare_diff: option<adsExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type attributionExecutiveSummaryWithForecastBreakdown = {
  attribution_sales: option<float>,
  attribution_spend: option<float>,
  attribution_impressions: option<float>,
  attribution_ctr: option<float>,
  attribution_clicks: option<float>,
  attribution_cvr: option<float>,
  attribution_orders: option<float>,
  attribution_units_sold: option<float>,
  attribution_acos: option<float>,
  attribution_roas: option<float>,
  attribution_cpc: option<float>,
  attribution_cpm: option<float>,
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
  compare_value: option<attributionExecutiveSummaryResponseSchema>,
  compare_diff: option<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: option<attributionExecutiveSummaryResponseSchema>,
  diff: option<attributionExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<attributionExecutiveSummaryResponseSchema>,
  compare_diff: option<attributionExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type cFOExecutiveSummaryWithForecastBreakdown = {
  available_capital: option<float>,
  frozen_capital: option<float>,
  borrowed_capital: option<float>,
  gross_profit: option<float>,
  gross_margin: option<float>,
  contribution_profit: option<float>,
  contribution_margin: option<float>,
  net_profit: option<float>,
  net_margin: option<float>,
  opex: option<float>,
  roi: option<float>,
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
  compare_value: option<cFOExecutiveSummaryResponseSchema>,
  compare_diff: option<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: option<cFOExecutiveSummaryResponseSchema>,
  diff: option<cFOExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<cFOExecutiveSummaryResponseSchema>,
  compare_diff: option<cFOExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type tierLevelForecastParams = {
  impressions_what_if: option<float>,
  clicks_what_if: option<float>,
  orders_what_if: option<float>,
  units_sold_what_if: option<float>,
  sales_what_if: option<float>,
  ad_spend_what_if: option<float>,
  ad_impressions_what_if: option<float>,
  ad_clicks_what_if: option<float>,
  ad_orders_what_if: option<float>,
  ad_sales_what_if: option<float>,
  ad_units_sold_what_if: option<float>,
  ad_ctr_what_if: option<float>,
  ad_cvr_what_if: option<float>,
  cpc_what_if: option<float>,
  cpm_what_if: option<float>,
  organic_impressions_what_if: option<float>,
  organic_clicks_what_if: option<float>,
  organic_orders_what_if: option<float>,
  organic_sales_what_if: option<float>,
  organic_units_sold_what_if: option<float>,
  total_sales_what_if: option<float>,
  total_spend_what_if: option<float>,
  total_impressions_what_if: option<float>,
  total_clicks_what_if: option<float>,
  total_orders_what_if: option<float>,
  total_units_sold_what_if: option<float>,
  lost_sales_what_if: option<float>,
  ctr_what_if: option<float>,
  cvr_what_if: option<float>,
  acos_what_if: option<float>,
  tacos_what_if: option<float>,
  roas_what_if: option<float>,
  mer_what_if: option<float>,
  aov_what_if: option<float>,
  gross_profit_what_if: option<float>,
  gross_margin_what_if: option<float>,
  contribution_profit_what_if: option<float>,
  contribution_margin_what_if: option<float>,
  net_profit_what_if: option<float>,
  net_margin_what_if: option<float>,
  roi_what_if: option<float>,
  available_capital_what_if: option<float>,
  frozen_capital_what_if: option<float>,
  ebitda_what_if: option<float>,
  cogs_what_if: option<float>,
  cost_of_goods_sold_what_if: option<float>,
  amazon_fees_what_if: option<float>,
  opex_what_if: option<float>,
  discount_what_if: option<float>,
  coupon_what_if: option<float>,
  subscribe_save_what_if: option<float>,
  text_score_what_if: option<float>,
  image_score_what_if: option<float>,
  video_score_what_if: option<float>,
  a_plus_score_what_if: option<float>,
  fba_in_stock_rate_what_if: option<float>,
  inventory_turnover_what_if: option<float>,
  safety_stock_what_if: option<float>,
  storage_costs_what_if: option<float>,
  shipping_costs_what_if: option<float>,
  market_total_sales_what_if: option<float>,
  brand_market_share_what_if: option<float>,
  market_average_price_what_if: option<float>,
  attribution_sales_what_if: option<float>,
  attribution_spend_what_if: option<float>,
  attribution_impressions_what_if: option<float>,
  attribution_clicks_what_if: option<float>,
  attribution_orders_what_if: option<float>,
  attribution_units_sold_what_if: option<float>,
  attribution_ctr_what_if: option<float>,
  attribution_cvr_what_if: option<float>,
  attribution_acos_what_if: option<float>,
  attribution_roas_what_if: option<float>,
  attribution_cpc_what_if: option<float>,
  attribution_cpm_what_if: option<float>,
  no_sales: option<forecastParams>,
  poor: option<forecastParams>,
  mid: option<forecastParams>,
  good: option<forecastParams>
}

@genType
@schema
type inventoryExecutiveSummaryWithForecastBreakdown = {
  fba_in_stock_rate: option<float>,
  fbt_in_stock_rate: option<float>,
  three_pl_in_stock_rate: option<float>,
  storage_costs: option<float>,
  shipping_costs: option<float>,
  forecasting_accuracy: option<float>,
  inventory_turnover: option<float>,
  safety_stock: option<float>,
  doi_available: option<float>,
  total_doi: option<float>,
  estimated_stock_out_date: option<string>,
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
  compare_value: option<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: option<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: option<inventoryExecutiveSummaryResponseSchema>,
  diff: option<inventoryExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<inventoryExecutiveSummaryResponseSchema>,
  compare_diff: option<inventoryExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  market_total_sales: option<float>,
  brand_market_share: option<float>,
  market_average_price: option<float>,
  market_total_units_sold: option<float>,
  market_asin_count: option<int>,
  market_promotion_value: option<float>,
  market_promotion_count: option<int>,
  market_review_score: option<float>,
  market_pos: option<float>,
  market_ad_spend: option<float>,
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
  compare_value: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  diff: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_diff: option<marketIntelligenceExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type organicExecutiveSummaryWithForecastBreakdown = {
  organic_sales: float,
  organic_impressions: option<float>,
  organic_ctr: option<float>,
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
  projected: option<organicExecutiveSummaryResponseSchema>,
  diff: option<organicExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<organicExecutiveSummaryResponseSchema>,
  compare_diff: option<organicExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  period_start: string,
  period_end: string,
  is_forecast: bool,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: option<totalExecutiveSummaryResponseSchema>,
  compare_diff: option<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<timelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type totalExecutiveSummaryWithForecastBreakdown = {
  total_sales: option<float>,
  total_spend: option<float>,
  total_impressions: option<float>,
  ctr: option<float>,
  total_clicks: option<float>,
  cvr: option<float>,
  total_orders: option<float>,
  total_units_sold: option<float>,
  total_ntb_orders: option<float>,
  tacos: option<float>,
  mer: option<float>,
  lost_sales: option<float>,
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
  projected: option<totalExecutiveSummaryResponseSchema>,
  diff: option<totalExecutiveSummaryResponseSchema>,
  percent_diff: option<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__percent_diff>,
  compare_value: option<totalExecutiveSummaryResponseSchema>,
  compare_diff: option<totalExecutiveSummaryResponseSchema>,
  compare_percent_diff: option<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff>
}

@genType
@schema
type inventoryMetricsResponse = {
  daily_metrics: array<dailyInventoryMetrics>,
  total_metrics: totalInventoryMetrics
}

@genType
@tag("_tag")
@schema
type whatifResponse_AdsExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema__whatif_applied = WhatifAppliedEntry(whatifAppliedEntry) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_AdsExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@tag("_tag")
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema__model_info = WhatifModelInfo(whatifModelInfo) | Dict(Dict.t<string>)

@genType
@schema
type timelineResponse_dict_ = {
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: option<string>
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
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<string>
}

@genType
@schema
type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_AdsExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_AdsExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_AttributionExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_AttributionExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_CFOExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_CFOExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_InventoryExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_InventoryExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_OrganicExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_OrganicExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}

@genType
@schema
type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<whatifResponse_TotalExecutiveSummaryResponseSchema__whatif_applied>,
  model_info: whatifResponse_TotalExecutiveSummaryResponseSchema__model_info,
  warnings: option<array<string>>
}