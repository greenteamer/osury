type adsExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  ad_sales: option<float>,
  ad_spend: option<float>,
  ad_impressions: option<float>,
  ad_ctr: option<option<float>>,
  ad_clicks: option<float>,
  ad_cvr: option<option<float>>,
  ad_orders: option<float>,
  ad_units_sold: option<float>,
  acos: option<option<float>>,
  roas: option<option<float>>,
  cpc: option<option<float>>,
  cpm: option<option<float>>,
  time_in_budget: option<option<float>>,
  ad_tos_is: option<option<float>>,
  ads_non_optimal_spend: option<option<float>>
}

type adsExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  ad_sales: option<float>,
  ad_spend: option<float>,
  ad_impressions: option<float>,
  ad_ctr: option<option<float>>,
  ad_clicks: option<float>,
  ad_cvr: option<option<float>>,
  ad_orders: option<float>,
  ad_units_sold: option<float>,
  acos: option<option<float>>,
  roas: option<option<float>>,
  cpc: option<option<float>>,
  cpm: option<option<float>>,
  time_in_budget: option<option<float>>,
  ad_tos_is: option<option<float>>,
  ads_non_optimal_spend: option<option<float>>,
  real: adsExecutiveSummaryResponseSchema,
  forecasted: adsExecutiveSummaryResponseSchema
}

type attributionExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  attribution_sales: option<option<float>>,
  attribution_spend: option<option<float>>,
  attribution_impressions: option<option<float>>,
  attribution_ctr: option<option<float>>,
  attribution_clicks: option<option<float>>,
  attribution_cvr: option<option<float>>,
  attribution_orders: option<option<float>>,
  attribution_units_sold: option<option<float>>,
  attribution_acos: option<option<float>>,
  attribution_roas: option<option<float>>,
  attribution_cpc: option<option<float>>,
  attribution_cpm: option<option<float>>
}

type attributionExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  attribution_sales: option<option<float>>,
  attribution_spend: option<option<float>>,
  attribution_impressions: option<option<float>>,
  attribution_ctr: option<option<float>>,
  attribution_clicks: option<option<float>>,
  attribution_cvr: option<option<float>>,
  attribution_orders: option<option<float>>,
  attribution_units_sold: option<option<float>>,
  attribution_acos: option<option<float>>,
  attribution_roas: option<option<float>>,
  attribution_cpc: option<option<float>>,
  attribution_cpm: option<option<float>>,
  real: attributionExecutiveSummaryResponseSchema,
  forecasted: attributionExecutiveSummaryResponseSchema
}

type cFOExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  available_capital: option<option<float>>,
  frozen_capital: option<option<float>>,
  borrowed_capital: option<option<float>>,
  gross_profit: option<option<float>>,
  gross_margin: option<option<float>>,
  contribution_profit: option<option<float>>,
  contribution_margin: option<option<float>>,
  net_profit: option<option<float>>,
  net_margin: option<option<float>>,
  opex: option<option<float>>,
  roi: option<option<float>>,
  cost_of_goods_sold: float,
  amazon_fees: float
}

type cFOExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  available_capital: option<option<float>>,
  frozen_capital: option<option<float>>,
  borrowed_capital: option<option<float>>,
  gross_profit: option<option<float>>,
  gross_margin: option<option<float>>,
  contribution_profit: option<option<float>>,
  contribution_margin: option<option<float>>,
  net_profit: option<option<float>>,
  net_margin: option<option<float>>,
  opex: option<option<float>>,
  roi: option<option<float>>,
  cost_of_goods_sold: float,
  amazon_fees: float,
  real: cFOExecutiveSummaryResponseSchema,
  forecasted: cFOExecutiveSummaryResponseSchema
}

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

type forecastParams = {
  impressions_what_if: option<option<float>>,
  clicks_what_if: option<option<float>>,
  orders_what_if: option<option<float>>,
  units_sold_what_if: option<option<float>>,
  sales_what_if: option<option<float>>,
  ad_spend_what_if: option<option<float>>,
  ad_impressions_what_if: option<option<float>>,
  ad_clicks_what_if: option<option<float>>,
  ad_orders_what_if: option<option<float>>,
  ad_sales_what_if: option<option<float>>,
  ad_units_sold_what_if: option<option<float>>,
  ad_ctr_what_if: option<option<float>>,
  ad_cvr_what_if: option<option<float>>,
  cpc_what_if: option<option<float>>,
  cpm_what_if: option<option<float>>,
  organic_impressions_what_if: option<option<float>>,
  organic_clicks_what_if: option<option<float>>,
  organic_orders_what_if: option<option<float>>,
  organic_sales_what_if: option<option<float>>,
  organic_units_sold_what_if: option<option<float>>,
  total_sales_what_if: option<option<float>>,
  total_spend_what_if: option<option<float>>,
  total_impressions_what_if: option<option<float>>,
  total_clicks_what_if: option<option<float>>,
  total_orders_what_if: option<option<float>>,
  total_units_sold_what_if: option<option<float>>,
  lost_sales_what_if: option<option<float>>,
  ctr_what_if: option<option<float>>,
  cvr_what_if: option<option<float>>,
  acos_what_if: option<option<float>>,
  tacos_what_if: option<option<float>>,
  roas_what_if: option<option<float>>,
  mer_what_if: option<option<float>>,
  aov_what_if: option<option<float>>,
  gross_profit_what_if: option<option<float>>,
  gross_margin_what_if: option<option<float>>,
  contribution_profit_what_if: option<option<float>>,
  contribution_margin_what_if: option<option<float>>,
  net_profit_what_if: option<option<float>>,
  net_margin_what_if: option<option<float>>,
  roi_what_if: option<option<float>>,
  available_capital_what_if: option<option<float>>,
  frozen_capital_what_if: option<option<float>>,
  ebitda_what_if: option<option<float>>,
  cogs_what_if: option<option<float>>,
  cost_of_goods_sold_what_if: option<option<float>>,
  amazon_fees_what_if: option<option<float>>,
  opex_what_if: option<option<float>>,
  discount_what_if: option<option<float>>,
  coupon_what_if: option<option<float>>,
  subscribe_save_what_if: option<option<float>>,
  text_score_what_if: option<option<float>>,
  image_score_what_if: option<option<float>>,
  video_score_what_if: option<option<float>>,
  a_plus_score_what_if: option<option<float>>,
  fba_in_stock_rate_what_if: option<option<float>>,
  inventory_turnover_what_if: option<option<float>>,
  safety_stock_what_if: option<option<float>>,
  storage_costs_what_if: option<option<float>>,
  shipping_costs_what_if: option<option<float>>,
  market_total_sales_what_if: option<option<float>>,
  brand_market_share_what_if: option<option<float>>,
  market_average_price_what_if: option<option<float>>,
  attribution_sales_what_if: option<option<float>>,
  attribution_spend_what_if: option<option<float>>,
  attribution_impressions_what_if: option<option<float>>,
  attribution_clicks_what_if: option<option<float>>,
  attribution_orders_what_if: option<option<float>>,
  attribution_units_sold_what_if: option<option<float>>,
  attribution_ctr_what_if: option<option<float>>,
  attribution_cvr_what_if: option<option<float>>,
  attribution_acos_what_if: option<option<float>>,
  attribution_roas_what_if: option<option<float>>,
  attribution_cpc_what_if: option<option<float>>,
  attribution_cpm_what_if: option<option<float>>
}

type hTTPValidationError = {
  detail: option<array<validationError>>
}

type insightResponse = {
  _tag: option<string>,
  summary: string,
  date_start: string,
  date_end: string,
  asin: option<option<string>>,
  agent: string
}

type inventoryExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  fba_in_stock_rate: option<option<float>>,
  fbt_in_stock_rate: option<option<float>>,
  three_pl_in_stock_rate: option<option<float>>,
  storage_costs: option<option<float>>,
  shipping_costs: option<option<float>>,
  forecasting_accuracy: option<option<float>>,
  inventory_turnover: option<option<float>>,
  safety_stock: option<option<float>>,
  doi_available: option<option<float>>,
  total_doi: option<option<float>>,
  estimated_stock_out_date: option<option<string>>
}

type inventoryExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  fba_in_stock_rate: option<option<float>>,
  fbt_in_stock_rate: option<option<float>>,
  three_pl_in_stock_rate: option<option<float>>,
  storage_costs: option<option<float>>,
  shipping_costs: option<option<float>>,
  forecasting_accuracy: option<option<float>>,
  inventory_turnover: option<option<float>>,
  safety_stock: option<option<float>>,
  doi_available: option<option<float>>,
  total_doi: option<option<float>>,
  estimated_stock_out_date: option<option<string>>,
  real: inventoryExecutiveSummaryResponseSchema,
  forecasted: inventoryExecutiveSummaryResponseSchema
}

type inventoryMetricsResponse = {
  _tag: option<string>,
  daily_metrics: array<dailyInventoryMetrics>,
  total_metrics: totalInventoryMetrics
}

type marketIntelligenceExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  market_total_sales: option<option<float>>,
  brand_market_share: option<option<float>>,
  market_average_price: option<option<float>>,
  market_total_units_sold: option<option<float>>,
  market_asin_count: option<option<int>>,
  market_promotion_value: option<option<float>>,
  market_promotion_count: option<option<int>>,
  market_review_score: option<option<float>>,
  market_pos: option<option<float>>,
  market_ad_spend: option<option<float>>
}

type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  market_total_sales: option<option<float>>,
  brand_market_share: option<option<float>>,
  market_average_price: option<option<float>>,
  market_total_units_sold: option<option<float>>,
  market_asin_count: option<option<int>>,
  market_promotion_value: option<option<float>>,
  market_promotion_count: option<option<int>>,
  market_review_score: option<option<float>>,
  market_pos: option<option<float>>,
  market_ad_spend: option<option<float>>,
  real: marketIntelligenceExecutiveSummaryResponseSchema,
  forecasted: marketIntelligenceExecutiveSummaryResponseSchema
}

type organicExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  organic_sales: float,
  organic_impressions: option<option<float>>,
  organic_ctr: option<option<float>>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float
}

type organicExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  organic_sales: float,
  organic_impressions: option<option<float>>,
  organic_ctr: option<option<float>>,
  organic_clicks: float,
  organic_cvr: float,
  organic_orders: float,
  organic_units_sold: float,
  real: organicExecutiveSummaryResponseSchema,
  forecasted: organicExecutiveSummaryResponseSchema
}

type strategicPlanResponse = {
  _tag: option<string>,
  plan: string,
  forecast_period: string,
  projected_total_sales: float,
  projected_net_profit: float,
  projected_gross_profit: float,
  projected_roi: float,
  total_sales_diff_pct: option<option<float>>,
  net_profit_diff_pct: option<option<float>>,
  gross_profit_diff_pct: option<option<float>>,
  roi_diff_pct: option<option<float>>,
  goals: option<array<Dict.t<string>>>,
  asin: option<option<string>>
}

type tierLevelForecastParams = {
  impressions_what_if: option<option<float>>,
  clicks_what_if: option<option<float>>,
  orders_what_if: option<option<float>>,
  units_sold_what_if: option<option<float>>,
  sales_what_if: option<option<float>>,
  ad_spend_what_if: option<option<float>>,
  ad_impressions_what_if: option<option<float>>,
  ad_clicks_what_if: option<option<float>>,
  ad_orders_what_if: option<option<float>>,
  ad_sales_what_if: option<option<float>>,
  ad_units_sold_what_if: option<option<float>>,
  ad_ctr_what_if: option<option<float>>,
  ad_cvr_what_if: option<option<float>>,
  cpc_what_if: option<option<float>>,
  cpm_what_if: option<option<float>>,
  organic_impressions_what_if: option<option<float>>,
  organic_clicks_what_if: option<option<float>>,
  organic_orders_what_if: option<option<float>>,
  organic_sales_what_if: option<option<float>>,
  organic_units_sold_what_if: option<option<float>>,
  total_sales_what_if: option<option<float>>,
  total_spend_what_if: option<option<float>>,
  total_impressions_what_if: option<option<float>>,
  total_clicks_what_if: option<option<float>>,
  total_orders_what_if: option<option<float>>,
  total_units_sold_what_if: option<option<float>>,
  lost_sales_what_if: option<option<float>>,
  ctr_what_if: option<option<float>>,
  cvr_what_if: option<option<float>>,
  acos_what_if: option<option<float>>,
  tacos_what_if: option<option<float>>,
  roas_what_if: option<option<float>>,
  mer_what_if: option<option<float>>,
  aov_what_if: option<option<float>>,
  gross_profit_what_if: option<option<float>>,
  gross_margin_what_if: option<option<float>>,
  contribution_profit_what_if: option<option<float>>,
  contribution_margin_what_if: option<option<float>>,
  net_profit_what_if: option<option<float>>,
  net_margin_what_if: option<option<float>>,
  roi_what_if: option<option<float>>,
  available_capital_what_if: option<option<float>>,
  frozen_capital_what_if: option<option<float>>,
  ebitda_what_if: option<option<float>>,
  cogs_what_if: option<option<float>>,
  cost_of_goods_sold_what_if: option<option<float>>,
  amazon_fees_what_if: option<option<float>>,
  opex_what_if: option<option<float>>,
  discount_what_if: option<option<float>>,
  coupon_what_if: option<option<float>>,
  subscribe_save_what_if: option<option<float>>,
  text_score_what_if: option<option<float>>,
  image_score_what_if: option<option<float>>,
  video_score_what_if: option<option<float>>,
  a_plus_score_what_if: option<option<float>>,
  fba_in_stock_rate_what_if: option<option<float>>,
  inventory_turnover_what_if: option<option<float>>,
  safety_stock_what_if: option<option<float>>,
  storage_costs_what_if: option<option<float>>,
  shipping_costs_what_if: option<option<float>>,
  market_total_sales_what_if: option<option<float>>,
  brand_market_share_what_if: option<option<float>>,
  market_average_price_what_if: option<option<float>>,
  attribution_sales_what_if: option<option<float>>,
  attribution_spend_what_if: option<option<float>>,
  attribution_impressions_what_if: option<option<float>>,
  attribution_clicks_what_if: option<option<float>>,
  attribution_orders_what_if: option<option<float>>,
  attribution_units_sold_what_if: option<option<float>>,
  attribution_ctr_what_if: option<option<float>>,
  attribution_cvr_what_if: option<option<float>>,
  attribution_acos_what_if: option<option<float>>,
  attribution_roas_what_if: option<option<float>>,
  attribution_cpc_what_if: option<option<float>>,
  attribution_cpm_what_if: option<option<float>>,
  no_sales: option<option<forecastParams>>,
  poor: option<option<forecastParams>>,
  mid: option<option<forecastParams>>,
  good: option<option<forecastParams>>
}

type timelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: adsExecutiveSummaryResponseSchema,
  compare_value: option<option<adsExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<adsExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: attributionExecutiveSummaryResponseSchema,
  compare_value: option<option<attributionExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<attributionExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: cFOExecutiveSummaryResponseSchema,
  compare_value: option<option<cFOExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<cFOExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: inventoryExecutiveSummaryResponseSchema,
  compare_value: option<option<inventoryExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<inventoryExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: marketIntelligenceExecutiveSummaryResponseSchema,
  compare_value: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: totalExecutiveSummaryResponseSchema,
  compare_value: option<option<totalExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<totalExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineDataPoint_dict_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  value: Dict.t<string>,
  compare_value: option<option<Dict.t<string>>>,
  compare_diff: option<option<Dict.t<string>>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type timelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type timelineResponse_dict_ = {
  _tag: option<string>,
  data: array<timelineDataPoint_dict_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type totalExecutiveSummaryResponseSchema = {
  _tag: option<string>,
  total_sales: option<option<float>>,
  total_spend: option<option<float>>,
  total_impressions: option<option<float>>,
  ctr: option<option<float>>,
  total_clicks: option<option<float>>,
  cvr: option<option<float>>,
  total_orders: option<option<float>>,
  total_units_sold: option<option<float>>,
  total_ntb_orders: option<option<float>>,
  tacos: option<option<float>>,
  mer: option<option<float>>,
  lost_sales: option<option<float>>
}

type totalExecutiveSummaryWithForecastBreakdown = {
  _tag: option<string>,
  total_sales: option<option<float>>,
  total_spend: option<option<float>>,
  total_impressions: option<option<float>>,
  ctr: option<option<float>>,
  total_clicks: option<option<float>>,
  cvr: option<option<float>>,
  total_orders: option<option<float>>,
  total_units_sold: option<option<float>>,
  total_ntb_orders: option<option<float>>,
  tacos: option<option<float>>,
  mer: option<option<float>>,
  lost_sales: option<option<float>>,
  real: totalExecutiveSummaryResponseSchema,
  forecasted: totalExecutiveSummaryResponseSchema
}

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

type validationError = {
  loc: array<[#Value(string) | #Value(int)]>,
  msg: string,
  type: string
}

type whatifAppliedEntry = {
  current_value: option<float>,
  percentage_change: float,
  target_value: option<float>
}

type whatifModelInfo = {
  metrics_count: int,
  correlations_count: int,
  data_points: int
}

type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: adsExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: attributionExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: cFOExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: inventoryExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: marketIntelligenceExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: organicExecutiveSummaryResponseSchema,
  projected: organicExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  baseline: totalExecutiveSummaryResponseSchema,
  projected: totalExecutiveSummaryResponseSchema,
  diff: Dict.t<option<float>>,
  percent_diff: Dict.t<option<float>>,
  whatif_applied: Dict.t<[#WhatifAppliedEntry(whatifAppliedEntry) | #Value(Dict.t<string>)]>,
  model_info: [#WhatifModelInfo(whatifModelInfo) | #Value(Dict.t<string>)],
  warnings: option<option<array<string>>>
}

type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: adsExecutiveSummaryResponseSchema,
  projected: option<option<adsExecutiveSummaryResponseSchema>>,
  diff: option<option<adsExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<adsExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<adsExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: attributionExecutiveSummaryResponseSchema,
  projected: option<option<attributionExecutiveSummaryResponseSchema>>,
  diff: option<option<attributionExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<attributionExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<attributionExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: cFOExecutiveSummaryResponseSchema,
  projected: option<option<cFOExecutiveSummaryResponseSchema>>,
  diff: option<option<cFOExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<cFOExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<cFOExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: inventoryExecutiveSummaryResponseSchema,
  projected: option<option<inventoryExecutiveSummaryResponseSchema>>,
  diff: option<option<inventoryExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<inventoryExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<inventoryExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: marketIntelligenceExecutiveSummaryResponseSchema,
  projected: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  diff: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<marketIntelligenceExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: organicExecutiveSummaryResponseSchema,
  projected: option<option<organicExecutiveSummaryResponseSchema>>,
  diff: option<option<organicExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<organicExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<organicExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  period_start: string,
  period_end: string,
  is_forecast: option<bool>,
  baseline: totalExecutiveSummaryResponseSchema,
  projected: option<option<totalExecutiveSummaryResponseSchema>>,
  diff: option<option<totalExecutiveSummaryResponseSchema>>,
  percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>,
  compare_value: option<option<totalExecutiveSummaryResponseSchema>>,
  compare_diff: option<option<totalExecutiveSummaryResponseSchema>>,
  compare_percent_diff: option<option<[#Value(float) | #Value(Dict.t<string>)]>>
}

type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}

type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  _tag: option<string>,
  data: array<whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_>,
  period_start: string,
  period_end: string,
  period: option<option<string>>
}