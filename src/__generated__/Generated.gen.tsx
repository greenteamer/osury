/* TypeScript file generated from Generated.res by genType. */

/* eslint-disable */
/* tslint:disable */

import type {t as Dict_t} from './Dict.gen';

import type {t as Nullable_t} from './Nullable.gen';

export type floatOrDict = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type stringOrInt = string | number;

export type adsExecutiveSummaryResponseSchema = {
  readonly ad_sales: number; 
  readonly ad_spend: number; 
  readonly ad_impressions: number; 
  readonly ad_ctr: Nullable_t<number>; 
  readonly ad_clicks: number; 
  readonly ad_cvr: Nullable_t<number>; 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: Nullable_t<number>; 
  readonly roas: Nullable_t<number>; 
  readonly cpc: Nullable_t<number>; 
  readonly cpm: Nullable_t<number>; 
  readonly time_in_budget: Nullable_t<number>; 
  readonly ad_tos_is: Nullable_t<number>; 
  readonly ads_non_optimal_spend: Nullable_t<number>
};

export type attributionExecutiveSummaryResponseSchema = {
  readonly attribution_sales: Nullable_t<number>; 
  readonly attribution_spend: Nullable_t<number>; 
  readonly attribution_impressions: Nullable_t<number>; 
  readonly attribution_ctr: Nullable_t<number>; 
  readonly attribution_clicks: Nullable_t<number>; 
  readonly attribution_cvr: Nullable_t<number>; 
  readonly attribution_orders: Nullable_t<number>; 
  readonly attribution_units_sold: Nullable_t<number>; 
  readonly attribution_acos: Nullable_t<number>; 
  readonly attribution_roas: Nullable_t<number>; 
  readonly attribution_cpc: Nullable_t<number>; 
  readonly attribution_cpm: Nullable_t<number>
};

export type cFOExecutiveSummaryResponseSchema = {
  readonly available_capital: Nullable_t<number>; 
  readonly frozen_capital: Nullable_t<number>; 
  readonly borrowed_capital: Nullable_t<number>; 
  readonly gross_profit: Nullable_t<number>; 
  readonly gross_margin: Nullable_t<number>; 
  readonly contribution_profit: Nullable_t<number>; 
  readonly contribution_margin: Nullable_t<number>; 
  readonly net_profit: Nullable_t<number>; 
  readonly net_margin: Nullable_t<number>; 
  readonly opex: Nullable_t<number>; 
  readonly roi: Nullable_t<number>; 
  readonly cost_of_goods_sold: number; 
  readonly amazon_fees: number
};

export type dailyInventoryMetrics = {
  readonly date: string; 
  readonly available_stock: number; 
  readonly in_transit: number; 
  readonly receiving: number; 
  readonly safety_stock: number; 
  readonly total_available: number; 
  readonly total_units_sold_30d: number; 
  readonly doi_available: number; 
  readonly total_doi: number
};

export type forecastParams = {
  readonly impressions_what_if: Nullable_t<number>; 
  readonly clicks_what_if: Nullable_t<number>; 
  readonly orders_what_if: Nullable_t<number>; 
  readonly units_sold_what_if: Nullable_t<number>; 
  readonly sales_what_if: Nullable_t<number>; 
  readonly ad_spend_what_if: Nullable_t<number>; 
  readonly ad_impressions_what_if: Nullable_t<number>; 
  readonly ad_clicks_what_if: Nullable_t<number>; 
  readonly ad_orders_what_if: Nullable_t<number>; 
  readonly ad_sales_what_if: Nullable_t<number>; 
  readonly ad_units_sold_what_if: Nullable_t<number>; 
  readonly ad_ctr_what_if: Nullable_t<number>; 
  readonly ad_cvr_what_if: Nullable_t<number>; 
  readonly cpc_what_if: Nullable_t<number>; 
  readonly cpm_what_if: Nullable_t<number>; 
  readonly organic_impressions_what_if: Nullable_t<number>; 
  readonly organic_clicks_what_if: Nullable_t<number>; 
  readonly organic_orders_what_if: Nullable_t<number>; 
  readonly organic_sales_what_if: Nullable_t<number>; 
  readonly organic_units_sold_what_if: Nullable_t<number>; 
  readonly total_sales_what_if: Nullable_t<number>; 
  readonly total_spend_what_if: Nullable_t<number>; 
  readonly total_impressions_what_if: Nullable_t<number>; 
  readonly total_clicks_what_if: Nullable_t<number>; 
  readonly total_orders_what_if: Nullable_t<number>; 
  readonly total_units_sold_what_if: Nullable_t<number>; 
  readonly lost_sales_what_if: Nullable_t<number>; 
  readonly ctr_what_if: Nullable_t<number>; 
  readonly cvr_what_if: Nullable_t<number>; 
  readonly acos_what_if: Nullable_t<number>; 
  readonly tacos_what_if: Nullable_t<number>; 
  readonly roas_what_if: Nullable_t<number>; 
  readonly mer_what_if: Nullable_t<number>; 
  readonly aov_what_if: Nullable_t<number>; 
  readonly gross_profit_what_if: Nullable_t<number>; 
  readonly gross_margin_what_if: Nullable_t<number>; 
  readonly contribution_profit_what_if: Nullable_t<number>; 
  readonly contribution_margin_what_if: Nullable_t<number>; 
  readonly net_profit_what_if: Nullable_t<number>; 
  readonly net_margin_what_if: Nullable_t<number>; 
  readonly roi_what_if: Nullable_t<number>; 
  readonly available_capital_what_if: Nullable_t<number>; 
  readonly frozen_capital_what_if: Nullable_t<number>; 
  readonly ebitda_what_if: Nullable_t<number>; 
  readonly cogs_what_if: Nullable_t<number>; 
  readonly cost_of_goods_sold_what_if: Nullable_t<number>; 
  readonly amazon_fees_what_if: Nullable_t<number>; 
  readonly opex_what_if: Nullable_t<number>; 
  readonly discount_what_if: Nullable_t<number>; 
  readonly coupon_what_if: Nullable_t<number>; 
  readonly subscribe_save_what_if: Nullable_t<number>; 
  readonly text_score_what_if: Nullable_t<number>; 
  readonly image_score_what_if: Nullable_t<number>; 
  readonly video_score_what_if: Nullable_t<number>; 
  readonly a_plus_score_what_if: Nullable_t<number>; 
  readonly fba_in_stock_rate_what_if: Nullable_t<number>; 
  readonly inventory_turnover_what_if: Nullable_t<number>; 
  readonly safety_stock_what_if: Nullable_t<number>; 
  readonly storage_costs_what_if: Nullable_t<number>; 
  readonly shipping_costs_what_if: Nullable_t<number>; 
  readonly market_total_sales_what_if: Nullable_t<number>; 
  readonly brand_market_share_what_if: Nullable_t<number>; 
  readonly market_average_price_what_if: Nullable_t<number>; 
  readonly attribution_sales_what_if: Nullable_t<number>; 
  readonly attribution_spend_what_if: Nullable_t<number>; 
  readonly attribution_impressions_what_if: Nullable_t<number>; 
  readonly attribution_clicks_what_if: Nullable_t<number>; 
  readonly attribution_orders_what_if: Nullable_t<number>; 
  readonly attribution_units_sold_what_if: Nullable_t<number>; 
  readonly attribution_ctr_what_if: Nullable_t<number>; 
  readonly attribution_cvr_what_if: Nullable_t<number>; 
  readonly attribution_acos_what_if: Nullable_t<number>; 
  readonly attribution_roas_what_if: Nullable_t<number>; 
  readonly attribution_cpc_what_if: Nullable_t<number>; 
  readonly attribution_cpm_what_if: Nullable_t<number>
};

export type insightResponse = {
  readonly summary: string; 
  readonly date_start: string; 
  readonly date_end: string; 
  readonly asin: Nullable_t<string>; 
  readonly agent: string
};

export type inventoryExecutiveSummaryResponseSchema = {
  readonly fba_in_stock_rate: Nullable_t<number>; 
  readonly fbt_in_stock_rate: Nullable_t<number>; 
  readonly three_pl_in_stock_rate: Nullable_t<number>; 
  readonly storage_costs: Nullable_t<number>; 
  readonly shipping_costs: Nullable_t<number>; 
  readonly forecasting_accuracy: Nullable_t<number>; 
  readonly inventory_turnover: Nullable_t<number>; 
  readonly safety_stock: Nullable_t<number>; 
  readonly doi_available: Nullable_t<number>; 
  readonly total_doi: Nullable_t<number>; 
  readonly estimated_stock_out_date: Nullable_t<string>
};

export type marketIntelligenceExecutiveSummaryResponseSchema = {
  readonly market_total_sales: Nullable_t<number>; 
  readonly brand_market_share: Nullable_t<number>; 
  readonly market_average_price: Nullable_t<number>; 
  readonly market_total_units_sold: Nullable_t<number>; 
  readonly market_asin_count: Nullable_t<number>; 
  readonly market_promotion_value: Nullable_t<number>; 
  readonly market_promotion_count: Nullable_t<number>; 
  readonly market_review_score: Nullable_t<number>; 
  readonly market_pos: Nullable_t<number>; 
  readonly market_ad_spend: Nullable_t<number>
};

export type organicExecutiveSummaryResponseSchema = {
  readonly organic_sales: number; 
  readonly organic_impressions: Nullable_t<number>; 
  readonly organic_ctr: Nullable_t<number>; 
  readonly organic_clicks: number; 
  readonly organic_cvr: number; 
  readonly organic_orders: number; 
  readonly organic_units_sold: number
};

export type strategicPlanResponse = {
  readonly plan: string; 
  readonly forecast_period: string; 
  readonly projected_total_sales: number; 
  readonly projected_net_profit: number; 
  readonly projected_gross_profit: number; 
  readonly projected_roi: number; 
  readonly total_sales_diff_pct: Nullable_t<number>; 
  readonly net_profit_diff_pct: Nullable_t<number>; 
  readonly gross_profit_diff_pct: Nullable_t<number>; 
  readonly roi_diff_pct: Nullable_t<number>; 
  readonly goals: (undefined | Dict_t<string>[]); 
  readonly asin: Nullable_t<string>
};

export type totalExecutiveSummaryResponseSchema = {
  readonly total_sales: Nullable_t<number>; 
  readonly total_spend: Nullable_t<number>; 
  readonly total_impressions: Nullable_t<number>; 
  readonly ctr: Nullable_t<number>; 
  readonly total_clicks: Nullable_t<number>; 
  readonly cvr: Nullable_t<number>; 
  readonly total_orders: Nullable_t<number>; 
  readonly total_units_sold: Nullable_t<number>; 
  readonly total_ntb_orders: Nullable_t<number>; 
  readonly tacos: Nullable_t<number>; 
  readonly mer: Nullable_t<number>; 
  readonly lost_sales: Nullable_t<number>
};

export type totalInventoryMetrics = {
  readonly available_stock: number; 
  readonly in_transit: number; 
  readonly receiving: number; 
  readonly safety_stock: number; 
  readonly total_available: number; 
  readonly total_units_sold_30d: number; 
  readonly doi_available: number; 
  readonly total_doi: number
};

export type whatifAppliedEntry = {
  readonly current_value: Nullable_t<number>; 
  readonly percentage_change: number; 
  readonly target_value: Nullable_t<number>
};

export type whatifModelInfo = {
  readonly metrics_count: number; 
  readonly correlations_count: number; 
  readonly data_points: number
};

export type timelineDataPoint_dict_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: Dict_t<string>; 
  readonly compare_value: Nullable_t<Dict_t<string>>; 
  readonly compare_diff: Nullable_t<Dict_t<string>>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type validationError = {
  readonly loc: stringOrInt[]; 
  readonly msg: string; 
  readonly type: string
};

export type adsExecutiveSummaryWithForecastBreakdown = {
  readonly ad_sales: number; 
  readonly ad_spend: number; 
  readonly ad_impressions: number; 
  readonly ad_ctr: Nullable_t<number>; 
  readonly ad_clicks: number; 
  readonly ad_cvr: Nullable_t<number>; 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: Nullable_t<number>; 
  readonly roas: Nullable_t<number>; 
  readonly cpc: Nullable_t<number>; 
  readonly cpm: Nullable_t<number>; 
  readonly time_in_budget: Nullable_t<number>; 
  readonly ad_tos_is: Nullable_t<number>; 
  readonly ads_non_optimal_spend: Nullable_t<number>; 
  readonly real: adsExecutiveSummaryResponseSchema; 
  readonly forecasted: adsExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: adsExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<adsExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type attributionExecutiveSummaryWithForecastBreakdown = {
  readonly attribution_sales: Nullable_t<number>; 
  readonly attribution_spend: Nullable_t<number>; 
  readonly attribution_impressions: Nullable_t<number>; 
  readonly attribution_ctr: Nullable_t<number>; 
  readonly attribution_clicks: Nullable_t<number>; 
  readonly attribution_cvr: Nullable_t<number>; 
  readonly attribution_orders: Nullable_t<number>; 
  readonly attribution_units_sold: Nullable_t<number>; 
  readonly attribution_acos: Nullable_t<number>; 
  readonly attribution_roas: Nullable_t<number>; 
  readonly attribution_cpc: Nullable_t<number>; 
  readonly attribution_cpm: Nullable_t<number>; 
  readonly real: attributionExecutiveSummaryResponseSchema; 
  readonly forecasted: attributionExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: attributionExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type cFOExecutiveSummaryWithForecastBreakdown = {
  readonly available_capital: Nullable_t<number>; 
  readonly frozen_capital: Nullable_t<number>; 
  readonly borrowed_capital: Nullable_t<number>; 
  readonly gross_profit: Nullable_t<number>; 
  readonly gross_margin: Nullable_t<number>; 
  readonly contribution_profit: Nullable_t<number>; 
  readonly contribution_margin: Nullable_t<number>; 
  readonly net_profit: Nullable_t<number>; 
  readonly net_margin: Nullable_t<number>; 
  readonly opex: Nullable_t<number>; 
  readonly roi: Nullable_t<number>; 
  readonly cost_of_goods_sold: number; 
  readonly amazon_fees: number; 
  readonly real: cFOExecutiveSummaryResponseSchema; 
  readonly forecasted: cFOExecutiveSummaryResponseSchema
};

export type timelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: cFOExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type tierLevelForecastParams = {
  readonly impressions_what_if: Nullable_t<number>; 
  readonly clicks_what_if: Nullable_t<number>; 
  readonly orders_what_if: Nullable_t<number>; 
  readonly units_sold_what_if: Nullable_t<number>; 
  readonly sales_what_if: Nullable_t<number>; 
  readonly ad_spend_what_if: Nullable_t<number>; 
  readonly ad_impressions_what_if: Nullable_t<number>; 
  readonly ad_clicks_what_if: Nullable_t<number>; 
  readonly ad_orders_what_if: Nullable_t<number>; 
  readonly ad_sales_what_if: Nullable_t<number>; 
  readonly ad_units_sold_what_if: Nullable_t<number>; 
  readonly ad_ctr_what_if: Nullable_t<number>; 
  readonly ad_cvr_what_if: Nullable_t<number>; 
  readonly cpc_what_if: Nullable_t<number>; 
  readonly cpm_what_if: Nullable_t<number>; 
  readonly organic_impressions_what_if: Nullable_t<number>; 
  readonly organic_clicks_what_if: Nullable_t<number>; 
  readonly organic_orders_what_if: Nullable_t<number>; 
  readonly organic_sales_what_if: Nullable_t<number>; 
  readonly organic_units_sold_what_if: Nullable_t<number>; 
  readonly total_sales_what_if: Nullable_t<number>; 
  readonly total_spend_what_if: Nullable_t<number>; 
  readonly total_impressions_what_if: Nullable_t<number>; 
  readonly total_clicks_what_if: Nullable_t<number>; 
  readonly total_orders_what_if: Nullable_t<number>; 
  readonly total_units_sold_what_if: Nullable_t<number>; 
  readonly lost_sales_what_if: Nullable_t<number>; 
  readonly ctr_what_if: Nullable_t<number>; 
  readonly cvr_what_if: Nullable_t<number>; 
  readonly acos_what_if: Nullable_t<number>; 
  readonly tacos_what_if: Nullable_t<number>; 
  readonly roas_what_if: Nullable_t<number>; 
  readonly mer_what_if: Nullable_t<number>; 
  readonly aov_what_if: Nullable_t<number>; 
  readonly gross_profit_what_if: Nullable_t<number>; 
  readonly gross_margin_what_if: Nullable_t<number>; 
  readonly contribution_profit_what_if: Nullable_t<number>; 
  readonly contribution_margin_what_if: Nullable_t<number>; 
  readonly net_profit_what_if: Nullable_t<number>; 
  readonly net_margin_what_if: Nullable_t<number>; 
  readonly roi_what_if: Nullable_t<number>; 
  readonly available_capital_what_if: Nullable_t<number>; 
  readonly frozen_capital_what_if: Nullable_t<number>; 
  readonly ebitda_what_if: Nullable_t<number>; 
  readonly cogs_what_if: Nullable_t<number>; 
  readonly cost_of_goods_sold_what_if: Nullable_t<number>; 
  readonly amazon_fees_what_if: Nullable_t<number>; 
  readonly opex_what_if: Nullable_t<number>; 
  readonly discount_what_if: Nullable_t<number>; 
  readonly coupon_what_if: Nullable_t<number>; 
  readonly subscribe_save_what_if: Nullable_t<number>; 
  readonly text_score_what_if: Nullable_t<number>; 
  readonly image_score_what_if: Nullable_t<number>; 
  readonly video_score_what_if: Nullable_t<number>; 
  readonly a_plus_score_what_if: Nullable_t<number>; 
  readonly fba_in_stock_rate_what_if: Nullable_t<number>; 
  readonly inventory_turnover_what_if: Nullable_t<number>; 
  readonly safety_stock_what_if: Nullable_t<number>; 
  readonly storage_costs_what_if: Nullable_t<number>; 
  readonly shipping_costs_what_if: Nullable_t<number>; 
  readonly market_total_sales_what_if: Nullable_t<number>; 
  readonly brand_market_share_what_if: Nullable_t<number>; 
  readonly market_average_price_what_if: Nullable_t<number>; 
  readonly attribution_sales_what_if: Nullable_t<number>; 
  readonly attribution_spend_what_if: Nullable_t<number>; 
  readonly attribution_impressions_what_if: Nullable_t<number>; 
  readonly attribution_clicks_what_if: Nullable_t<number>; 
  readonly attribution_orders_what_if: Nullable_t<number>; 
  readonly attribution_units_sold_what_if: Nullable_t<number>; 
  readonly attribution_ctr_what_if: Nullable_t<number>; 
  readonly attribution_cvr_what_if: Nullable_t<number>; 
  readonly attribution_acos_what_if: Nullable_t<number>; 
  readonly attribution_roas_what_if: Nullable_t<number>; 
  readonly attribution_cpc_what_if: Nullable_t<number>; 
  readonly attribution_cpm_what_if: Nullable_t<number>; 
  readonly no_sales: Nullable_t<forecastParams>; 
  readonly poor: Nullable_t<forecastParams>; 
  readonly mid: Nullable_t<forecastParams>; 
  readonly good: Nullable_t<forecastParams>
};

export type getV1MathInsightsTotalResponse = insightResponse;

export type getV1MathInsightsMarketResponse = insightResponse;

export type getV1MathInsightsAdsResponse = insightResponse;

export type getV1MathInsightsOrganicResponse = insightResponse;

export type getV1MathInsightsAttributionResponse = insightResponse;

export type getV1MathInsightsCfoResponse = insightResponse;

export type getV1MathInsightsInventoryResponse = insightResponse;

export type inventoryExecutiveSummaryWithForecastBreakdown = {
  readonly fba_in_stock_rate: Nullable_t<number>; 
  readonly fbt_in_stock_rate: Nullable_t<number>; 
  readonly three_pl_in_stock_rate: Nullable_t<number>; 
  readonly storage_costs: Nullable_t<number>; 
  readonly shipping_costs: Nullable_t<number>; 
  readonly forecasting_accuracy: Nullable_t<number>; 
  readonly inventory_turnover: Nullable_t<number>; 
  readonly safety_stock: Nullable_t<number>; 
  readonly doi_available: Nullable_t<number>; 
  readonly total_doi: Nullable_t<number>; 
  readonly estimated_stock_out_date: Nullable_t<string>; 
  readonly real: inventoryExecutiveSummaryResponseSchema; 
  readonly forecasted: inventoryExecutiveSummaryResponseSchema
};

export type timelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: inventoryExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  readonly market_total_sales: Nullable_t<number>; 
  readonly brand_market_share: Nullable_t<number>; 
  readonly market_average_price: Nullable_t<number>; 
  readonly market_total_units_sold: Nullable_t<number>; 
  readonly market_asin_count: Nullable_t<number>; 
  readonly market_promotion_value: Nullable_t<number>; 
  readonly market_promotion_count: Nullable_t<number>; 
  readonly market_review_score: Nullable_t<number>; 
  readonly market_pos: Nullable_t<number>; 
  readonly market_ad_spend: Nullable_t<number>; 
  readonly real: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly forecasted: marketIntelligenceExecutiveSummaryResponseSchema
};

export type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type organicExecutiveSummaryWithForecastBreakdown = {
  readonly organic_sales: number; 
  readonly organic_impressions: Nullable_t<number>; 
  readonly organic_ctr: Nullable_t<number>; 
  readonly organic_clicks: number; 
  readonly organic_cvr: number; 
  readonly organic_orders: number; 
  readonly organic_units_sold: number; 
  readonly real: organicExecutiveSummaryResponseSchema; 
  readonly forecasted: organicExecutiveSummaryResponseSchema
};

export type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: organicExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<organicExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<organicExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<organicExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<organicExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type getV1MathInsightsStrategicPlanResponse = strategicPlanResponse;

export type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: totalExecutiveSummaryResponseSchema; 
  readonly compare_value: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type totalExecutiveSummaryWithForecastBreakdown = {
  readonly total_sales: Nullable_t<number>; 
  readonly total_spend: Nullable_t<number>; 
  readonly total_impressions: Nullable_t<number>; 
  readonly ctr: Nullable_t<number>; 
  readonly total_clicks: Nullable_t<number>; 
  readonly cvr: Nullable_t<number>; 
  readonly total_orders: Nullable_t<number>; 
  readonly total_units_sold: Nullable_t<number>; 
  readonly total_ntb_orders: Nullable_t<number>; 
  readonly tacos: Nullable_t<number>; 
  readonly mer: Nullable_t<number>; 
  readonly lost_sales: Nullable_t<number>; 
  readonly real: totalExecutiveSummaryResponseSchema; 
  readonly forecasted: totalExecutiveSummaryResponseSchema
};

export type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly diff: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly percent_diff: Nullable_t<floatOrDict>; 
  readonly compare_value: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly compare_diff: Nullable_t<totalExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: Nullable_t<floatOrDict>
};

export type inventoryMetricsResponse = { readonly daily_metrics: dailyInventoryMetrics[]; readonly total_metrics: totalInventoryMetrics };

export type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: adsExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: attributionExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: cFOExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: inventoryExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly baseline: organicExecutiveSummaryResponseSchema; 
  readonly projected: organicExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: totalExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<Nullable_t<number>>; 
  readonly percent_diff: Dict_t<Nullable_t<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: Nullable_t<string[]>
};

export type timelineResponse_dict_ = {
  readonly data: timelineDataPoint_dict_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type hTTPValidationError = { readonly detail: (undefined | validationError[]) };

export type timelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: Nullable_t<string>
};

export type getV1MathInventoryMetricsResponse = 
    { _tag: "InventoryMetricsResponse"; readonly daily_metrics: dailyInventoryMetrics[]; readonly total_metrics: totalInventoryMetrics }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_dict_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: Dict_t<string>; readonly compare_value: Nullable_t<Dict_t<string>>; readonly compare_diff: Nullable_t<Dict_t<string>>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type getV1MathOrganicExecutiveSummaryResponse = 
    { _tag: "OrganicExecutiveSummaryResponseSchema"; readonly organic_sales: number; readonly organic_impressions: Nullable_t<number>; readonly organic_ctr: Nullable_t<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number }
  | { _tag: "OrganicExecutiveSummaryWithForecastBreakdown"; readonly organic_sales: number; readonly organic_impressions: Nullable_t<number>; readonly organic_ctr: Nullable_t<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number; readonly real: organicExecutiveSummaryResponseSchema; readonly forecasted: organicExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_dict_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: Dict_t<string>; readonly compare_value: Nullable_t<Dict_t<string>>; readonly compare_diff: Nullable_t<Dict_t<string>>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type getV1MathAdsExecutiveSummaryResponse = 
    { _tag: "AdsExecutiveSummaryResponseSchema"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: Nullable_t<number>; readonly ad_clicks: number; readonly ad_cvr: Nullable_t<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: Nullable_t<number>; readonly roas: Nullable_t<number>; readonly cpc: Nullable_t<number>; readonly cpm: Nullable_t<number>; readonly time_in_budget: Nullable_t<number>; readonly ad_tos_is: Nullable_t<number>; readonly ads_non_optimal_spend: Nullable_t<number> }
  | { _tag: "AdsExecutiveSummaryWithForecastBreakdown"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: Nullable_t<number>; readonly ad_clicks: number; readonly ad_cvr: Nullable_t<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: Nullable_t<number>; readonly roas: Nullable_t<number>; readonly cpc: Nullable_t<number>; readonly cpm: Nullable_t<number>; readonly time_in_budget: Nullable_t<number>; readonly ad_tos_is: Nullable_t<number>; readonly ads_non_optimal_spend: Nullable_t<number>; readonly real: adsExecutiveSummaryResponseSchema; readonly forecasted: adsExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: adsExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<adsExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<adsExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathAdsExecutiveSummaryResponse = 
    { _tag: "AdsExecutiveSummaryResponseSchema"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: Nullable_t<number>; readonly ad_clicks: number; readonly ad_cvr: Nullable_t<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: Nullable_t<number>; readonly roas: Nullable_t<number>; readonly cpc: Nullable_t<number>; readonly cpm: Nullable_t<number>; readonly time_in_budget: Nullable_t<number>; readonly ad_tos_is: Nullable_t<number>; readonly ads_non_optimal_spend: Nullable_t<number> }
  | { _tag: "AdsExecutiveSummaryWithForecastBreakdown"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: Nullable_t<number>; readonly ad_clicks: number; readonly ad_cvr: Nullable_t<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: Nullable_t<number>; readonly roas: Nullable_t<number>; readonly cpc: Nullable_t<number>; readonly cpm: Nullable_t<number>; readonly time_in_budget: Nullable_t<number>; readonly ad_tos_is: Nullable_t<number>; readonly ads_non_optimal_spend: Nullable_t<number>; readonly real: adsExecutiveSummaryResponseSchema; readonly forecasted: adsExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: adsExecutiveSummaryResponseSchema; readonly projected: adsExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type getV1MathAttributionExecutiveSummaryResponse = 
    { _tag: "AttributionExecutiveSummaryResponseSchema"; readonly attribution_sales: Nullable_t<number>; readonly attribution_spend: Nullable_t<number>; readonly attribution_impressions: Nullable_t<number>; readonly attribution_ctr: Nullable_t<number>; readonly attribution_clicks: Nullable_t<number>; readonly attribution_cvr: Nullable_t<number>; readonly attribution_orders: Nullable_t<number>; readonly attribution_units_sold: Nullable_t<number>; readonly attribution_acos: Nullable_t<number>; readonly attribution_roas: Nullable_t<number>; readonly attribution_cpc: Nullable_t<number>; readonly attribution_cpm: Nullable_t<number> }
  | { _tag: "AttributionExecutiveSummaryWithForecastBreakdown"; readonly attribution_sales: Nullable_t<number>; readonly attribution_spend: Nullable_t<number>; readonly attribution_impressions: Nullable_t<number>; readonly attribution_ctr: Nullable_t<number>; readonly attribution_clicks: Nullable_t<number>; readonly attribution_cvr: Nullable_t<number>; readonly attribution_orders: Nullable_t<number>; readonly attribution_units_sold: Nullable_t<number>; readonly attribution_acos: Nullable_t<number>; readonly attribution_roas: Nullable_t<number>; readonly attribution_cpc: Nullable_t<number>; readonly attribution_cpm: Nullable_t<number>; readonly real: attributionExecutiveSummaryResponseSchema; readonly forecasted: attributionExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: attributionExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<attributionExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<attributionExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathAttributionExecutiveSummaryResponse = 
    { _tag: "AttributionExecutiveSummaryResponseSchema"; readonly attribution_sales: Nullable_t<number>; readonly attribution_spend: Nullable_t<number>; readonly attribution_impressions: Nullable_t<number>; readonly attribution_ctr: Nullable_t<number>; readonly attribution_clicks: Nullable_t<number>; readonly attribution_cvr: Nullable_t<number>; readonly attribution_orders: Nullable_t<number>; readonly attribution_units_sold: Nullable_t<number>; readonly attribution_acos: Nullable_t<number>; readonly attribution_roas: Nullable_t<number>; readonly attribution_cpc: Nullable_t<number>; readonly attribution_cpm: Nullable_t<number> }
  | { _tag: "AttributionExecutiveSummaryWithForecastBreakdown"; readonly attribution_sales: Nullable_t<number>; readonly attribution_spend: Nullable_t<number>; readonly attribution_impressions: Nullable_t<number>; readonly attribution_ctr: Nullable_t<number>; readonly attribution_clicks: Nullable_t<number>; readonly attribution_cvr: Nullable_t<number>; readonly attribution_orders: Nullable_t<number>; readonly attribution_units_sold: Nullable_t<number>; readonly attribution_acos: Nullable_t<number>; readonly attribution_roas: Nullable_t<number>; readonly attribution_cpc: Nullable_t<number>; readonly attribution_cpm: Nullable_t<number>; readonly real: attributionExecutiveSummaryResponseSchema; readonly forecasted: attributionExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: attributionExecutiveSummaryResponseSchema; readonly projected: attributionExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type getV1MathCfoExecutiveSummaryResponse = 
    { _tag: "CFOExecutiveSummaryResponseSchema"; readonly available_capital: Nullable_t<number>; readonly frozen_capital: Nullable_t<number>; readonly borrowed_capital: Nullable_t<number>; readonly gross_profit: Nullable_t<number>; readonly gross_margin: Nullable_t<number>; readonly contribution_profit: Nullable_t<number>; readonly contribution_margin: Nullable_t<number>; readonly net_profit: Nullable_t<number>; readonly net_margin: Nullable_t<number>; readonly opex: Nullable_t<number>; readonly roi: Nullable_t<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number }
  | { _tag: "CFOExecutiveSummaryWithForecastBreakdown"; readonly available_capital: Nullable_t<number>; readonly frozen_capital: Nullable_t<number>; readonly borrowed_capital: Nullable_t<number>; readonly gross_profit: Nullable_t<number>; readonly gross_margin: Nullable_t<number>; readonly contribution_profit: Nullable_t<number>; readonly contribution_margin: Nullable_t<number>; readonly net_profit: Nullable_t<number>; readonly net_margin: Nullable_t<number>; readonly opex: Nullable_t<number>; readonly roi: Nullable_t<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number; readonly real: cFOExecutiveSummaryResponseSchema; readonly forecasted: cFOExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: cFOExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<cFOExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<cFOExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathCfoExecutiveSummaryResponse = 
    { _tag: "CFOExecutiveSummaryResponseSchema"; readonly available_capital: Nullable_t<number>; readonly frozen_capital: Nullable_t<number>; readonly borrowed_capital: Nullable_t<number>; readonly gross_profit: Nullable_t<number>; readonly gross_margin: Nullable_t<number>; readonly contribution_profit: Nullable_t<number>; readonly contribution_margin: Nullable_t<number>; readonly net_profit: Nullable_t<number>; readonly net_margin: Nullable_t<number>; readonly opex: Nullable_t<number>; readonly roi: Nullable_t<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number }
  | { _tag: "CFOExecutiveSummaryWithForecastBreakdown"; readonly available_capital: Nullable_t<number>; readonly frozen_capital: Nullable_t<number>; readonly borrowed_capital: Nullable_t<number>; readonly gross_profit: Nullable_t<number>; readonly gross_margin: Nullable_t<number>; readonly contribution_profit: Nullable_t<number>; readonly contribution_margin: Nullable_t<number>; readonly net_profit: Nullable_t<number>; readonly net_margin: Nullable_t<number>; readonly opex: Nullable_t<number>; readonly roi: Nullable_t<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number; readonly real: cFOExecutiveSummaryResponseSchema; readonly forecasted: cFOExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: cFOExecutiveSummaryResponseSchema; readonly projected: cFOExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type getV1MathInventoryMetricsExecutiveSummaryResponse = 
    { _tag: "InventoryExecutiveSummaryResponseSchema"; readonly fba_in_stock_rate: Nullable_t<number>; readonly fbt_in_stock_rate: Nullable_t<number>; readonly three_pl_in_stock_rate: Nullable_t<number>; readonly storage_costs: Nullable_t<number>; readonly shipping_costs: Nullable_t<number>; readonly forecasting_accuracy: Nullable_t<number>; readonly inventory_turnover: Nullable_t<number>; readonly safety_stock: Nullable_t<number>; readonly doi_available: Nullable_t<number>; readonly total_doi: Nullable_t<number>; readonly estimated_stock_out_date: Nullable_t<string> }
  | { _tag: "InventoryExecutiveSummaryWithForecastBreakdown"; readonly fba_in_stock_rate: Nullable_t<number>; readonly fbt_in_stock_rate: Nullable_t<number>; readonly three_pl_in_stock_rate: Nullable_t<number>; readonly storage_costs: Nullable_t<number>; readonly shipping_costs: Nullable_t<number>; readonly forecasting_accuracy: Nullable_t<number>; readonly inventory_turnover: Nullable_t<number>; readonly safety_stock: Nullable_t<number>; readonly doi_available: Nullable_t<number>; readonly total_doi: Nullable_t<number>; readonly estimated_stock_out_date: Nullable_t<string>; readonly real: inventoryExecutiveSummaryResponseSchema; readonly forecasted: inventoryExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: inventoryExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<inventoryExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<inventoryExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathInventoryMetricsExecutiveSummaryResponse = 
    { _tag: "InventoryExecutiveSummaryResponseSchema"; readonly fba_in_stock_rate: Nullable_t<number>; readonly fbt_in_stock_rate: Nullable_t<number>; readonly three_pl_in_stock_rate: Nullable_t<number>; readonly storage_costs: Nullable_t<number>; readonly shipping_costs: Nullable_t<number>; readonly forecasting_accuracy: Nullable_t<number>; readonly inventory_turnover: Nullable_t<number>; readonly safety_stock: Nullable_t<number>; readonly doi_available: Nullable_t<number>; readonly total_doi: Nullable_t<number>; readonly estimated_stock_out_date: Nullable_t<string> }
  | { _tag: "InventoryExecutiveSummaryWithForecastBreakdown"; readonly fba_in_stock_rate: Nullable_t<number>; readonly fbt_in_stock_rate: Nullable_t<number>; readonly three_pl_in_stock_rate: Nullable_t<number>; readonly storage_costs: Nullable_t<number>; readonly shipping_costs: Nullable_t<number>; readonly forecasting_accuracy: Nullable_t<number>; readonly inventory_turnover: Nullable_t<number>; readonly safety_stock: Nullable_t<number>; readonly doi_available: Nullable_t<number>; readonly total_doi: Nullable_t<number>; readonly estimated_stock_out_date: Nullable_t<string>; readonly real: inventoryExecutiveSummaryResponseSchema; readonly forecasted: inventoryExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: inventoryExecutiveSummaryResponseSchema; readonly projected: inventoryExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type getV1MathMarketIntelligenceExecutiveSummaryResponse = 
    { _tag: "MarketIntelligenceExecutiveSummaryResponseSchema"; readonly market_total_sales: Nullable_t<number>; readonly brand_market_share: Nullable_t<number>; readonly market_average_price: Nullable_t<number>; readonly market_total_units_sold: Nullable_t<number>; readonly market_asin_count: Nullable_t<number>; readonly market_promotion_value: Nullable_t<number>; readonly market_promotion_count: Nullable_t<number>; readonly market_review_score: Nullable_t<number>; readonly market_pos: Nullable_t<number>; readonly market_ad_spend: Nullable_t<number> }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: marketIntelligenceExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<marketIntelligenceExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathMarketIntelligenceExecutiveSummaryResponse = 
    { _tag: "MarketIntelligenceExecutiveSummaryResponseSchema"; readonly market_total_sales: Nullable_t<number>; readonly brand_market_share: Nullable_t<number>; readonly market_average_price: Nullable_t<number>; readonly market_total_units_sold: Nullable_t<number>; readonly market_asin_count: Nullable_t<number>; readonly market_promotion_value: Nullable_t<number>; readonly market_promotion_count: Nullable_t<number>; readonly market_review_score: Nullable_t<number>; readonly market_pos: Nullable_t<number>; readonly market_ad_spend: Nullable_t<number> }
  | { _tag: "MarketIntelligenceExecutiveSummaryWithForecastBreakdown"; readonly market_total_sales: Nullable_t<number>; readonly brand_market_share: Nullable_t<number>; readonly market_average_price: Nullable_t<number>; readonly market_total_units_sold: Nullable_t<number>; readonly market_asin_count: Nullable_t<number>; readonly market_promotion_value: Nullable_t<number>; readonly market_promotion_count: Nullable_t<number>; readonly market_review_score: Nullable_t<number>; readonly market_pos: Nullable_t<number>; readonly market_ad_spend: Nullable_t<number>; readonly real: marketIntelligenceExecutiveSummaryResponseSchema; readonly forecasted: marketIntelligenceExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; readonly projected: marketIntelligenceExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type postV1MathOrganicExecutiveSummaryResponse = 
    { _tag: "OrganicExecutiveSummaryResponseSchema"; readonly organic_sales: number; readonly organic_impressions: Nullable_t<number>; readonly organic_ctr: Nullable_t<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number }
  | { _tag: "OrganicExecutiveSummaryWithForecastBreakdown"; readonly organic_sales: number; readonly organic_impressions: Nullable_t<number>; readonly organic_ctr: Nullable_t<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number; readonly real: organicExecutiveSummaryResponseSchema; readonly forecasted: organicExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: organicExecutiveSummaryResponseSchema; readonly projected: organicExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };

export type getV1MathTotalExecutiveSummaryResponse = 
    { _tag: "TotalExecutiveSummaryResponseSchema"; readonly total_sales: Nullable_t<number>; readonly total_spend: Nullable_t<number>; readonly total_impressions: Nullable_t<number>; readonly ctr: Nullable_t<number>; readonly total_clicks: Nullable_t<number>; readonly cvr: Nullable_t<number>; readonly total_orders: Nullable_t<number>; readonly total_units_sold: Nullable_t<number>; readonly total_ntb_orders: Nullable_t<number>; readonly tacos: Nullable_t<number>; readonly mer: Nullable_t<number>; readonly lost_sales: Nullable_t<number> }
  | { _tag: "TotalExecutiveSummaryWithForecastBreakdown"; readonly total_sales: Nullable_t<number>; readonly total_spend: Nullable_t<number>; readonly total_impressions: Nullable_t<number>; readonly ctr: Nullable_t<number>; readonly total_clicks: Nullable_t<number>; readonly cvr: Nullable_t<number>; readonly total_orders: Nullable_t<number>; readonly total_units_sold: Nullable_t<number>; readonly total_ntb_orders: Nullable_t<number>; readonly tacos: Nullable_t<number>; readonly mer: Nullable_t<number>; readonly lost_sales: Nullable_t<number>; readonly real: totalExecutiveSummaryResponseSchema; readonly forecasted: totalExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: totalExecutiveSummaryResponseSchema; readonly compare_value: Nullable_t<totalExecutiveSummaryResponseSchema>; readonly compare_diff: Nullable_t<totalExecutiveSummaryResponseSchema>; readonly compare_percent_diff: Nullable_t<floatOrDict> };

export type postV1MathTotalExecutiveSummaryResponse = 
    { _tag: "TotalExecutiveSummaryResponseSchema"; readonly total_sales: Nullable_t<number>; readonly total_spend: Nullable_t<number>; readonly total_impressions: Nullable_t<number>; readonly ctr: Nullable_t<number>; readonly total_clicks: Nullable_t<number>; readonly cvr: Nullable_t<number>; readonly total_orders: Nullable_t<number>; readonly total_units_sold: Nullable_t<number>; readonly total_ntb_orders: Nullable_t<number>; readonly tacos: Nullable_t<number>; readonly mer: Nullable_t<number>; readonly lost_sales: Nullable_t<number> }
  | { _tag: "TotalExecutiveSummaryWithForecastBreakdown"; readonly total_sales: Nullable_t<number>; readonly total_spend: Nullable_t<number>; readonly total_impressions: Nullable_t<number>; readonly ctr: Nullable_t<number>; readonly total_clicks: Nullable_t<number>; readonly cvr: Nullable_t<number>; readonly total_orders: Nullable_t<number>; readonly total_units_sold: Nullable_t<number>; readonly total_ntb_orders: Nullable_t<number>; readonly tacos: Nullable_t<number>; readonly mer: Nullable_t<number>; readonly lost_sales: Nullable_t<number>; readonly real: totalExecutiveSummaryResponseSchema; readonly forecasted: totalExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: totalExecutiveSummaryResponseSchema; readonly projected: totalExecutiveSummaryResponseSchema; readonly diff: Dict_t<Nullable_t<number>>; readonly percent_diff: Dict_t<Nullable_t<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: Nullable_t<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: Nullable_t<string> };
