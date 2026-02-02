/* TypeScript file generated from Generated.res by genType. */

/* eslint-disable */
/* tslint:disable */

import type {t as $$null} from './Null.gen.ts';

import type {t as Dict_t} from './Dict.gen';

export type null<a> = $$null<a>;

export type floatOrDict = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type stringOrInt = string | number;

export type adsExecutiveSummaryResponseSchema = {
  readonly ad_sales: number; 
  readonly ad_spend: number; 
  readonly ad_impressions: number; 
  readonly ad_ctr: null<number>; 
  readonly ad_clicks: number; 
  readonly ad_cvr: null<number>; 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: null<number>; 
  readonly roas: null<number>; 
  readonly cpc: null<number>; 
  readonly cpm: null<number>; 
  readonly time_in_budget: null<number>; 
  readonly ad_tos_is: null<number>; 
  readonly ads_non_optimal_spend: null<number>
};

export type attributionExecutiveSummaryResponseSchema = {
  readonly attribution_sales: null<number>; 
  readonly attribution_spend: null<number>; 
  readonly attribution_impressions: null<number>; 
  readonly attribution_ctr: null<number>; 
  readonly attribution_clicks: null<number>; 
  readonly attribution_cvr: null<number>; 
  readonly attribution_orders: null<number>; 
  readonly attribution_units_sold: null<number>; 
  readonly attribution_acos: null<number>; 
  readonly attribution_roas: null<number>; 
  readonly attribution_cpc: null<number>; 
  readonly attribution_cpm: null<number>
};

export type cFOExecutiveSummaryResponseSchema = {
  readonly available_capital: null<number>; 
  readonly frozen_capital: null<number>; 
  readonly borrowed_capital: null<number>; 
  readonly gross_profit: null<number>; 
  readonly gross_margin: null<number>; 
  readonly contribution_profit: null<number>; 
  readonly contribution_margin: null<number>; 
  readonly net_profit: null<number>; 
  readonly net_margin: null<number>; 
  readonly opex: null<number>; 
  readonly roi: null<number>; 
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
  readonly impressions_what_if: null<number>; 
  readonly clicks_what_if: null<number>; 
  readonly orders_what_if: null<number>; 
  readonly units_sold_what_if: null<number>; 
  readonly sales_what_if: null<number>; 
  readonly ad_spend_what_if: null<number>; 
  readonly ad_impressions_what_if: null<number>; 
  readonly ad_clicks_what_if: null<number>; 
  readonly ad_orders_what_if: null<number>; 
  readonly ad_sales_what_if: null<number>; 
  readonly ad_units_sold_what_if: null<number>; 
  readonly ad_ctr_what_if: null<number>; 
  readonly ad_cvr_what_if: null<number>; 
  readonly cpc_what_if: null<number>; 
  readonly cpm_what_if: null<number>; 
  readonly organic_impressions_what_if: null<number>; 
  readonly organic_clicks_what_if: null<number>; 
  readonly organic_orders_what_if: null<number>; 
  readonly organic_sales_what_if: null<number>; 
  readonly organic_units_sold_what_if: null<number>; 
  readonly total_sales_what_if: null<number>; 
  readonly total_spend_what_if: null<number>; 
  readonly total_impressions_what_if: null<number>; 
  readonly total_clicks_what_if: null<number>; 
  readonly total_orders_what_if: null<number>; 
  readonly total_units_sold_what_if: null<number>; 
  readonly lost_sales_what_if: null<number>; 
  readonly ctr_what_if: null<number>; 
  readonly cvr_what_if: null<number>; 
  readonly acos_what_if: null<number>; 
  readonly tacos_what_if: null<number>; 
  readonly roas_what_if: null<number>; 
  readonly mer_what_if: null<number>; 
  readonly aov_what_if: null<number>; 
  readonly gross_profit_what_if: null<number>; 
  readonly gross_margin_what_if: null<number>; 
  readonly contribution_profit_what_if: null<number>; 
  readonly contribution_margin_what_if: null<number>; 
  readonly net_profit_what_if: null<number>; 
  readonly net_margin_what_if: null<number>; 
  readonly roi_what_if: null<number>; 
  readonly available_capital_what_if: null<number>; 
  readonly frozen_capital_what_if: null<number>; 
  readonly ebitda_what_if: null<number>; 
  readonly cogs_what_if: null<number>; 
  readonly cost_of_goods_sold_what_if: null<number>; 
  readonly amazon_fees_what_if: null<number>; 
  readonly opex_what_if: null<number>; 
  readonly discount_what_if: null<number>; 
  readonly coupon_what_if: null<number>; 
  readonly subscribe_save_what_if: null<number>; 
  readonly text_score_what_if: null<number>; 
  readonly image_score_what_if: null<number>; 
  readonly video_score_what_if: null<number>; 
  readonly a_plus_score_what_if: null<number>; 
  readonly fba_in_stock_rate_what_if: null<number>; 
  readonly inventory_turnover_what_if: null<number>; 
  readonly safety_stock_what_if: null<number>; 
  readonly storage_costs_what_if: null<number>; 
  readonly shipping_costs_what_if: null<number>; 
  readonly market_total_sales_what_if: null<number>; 
  readonly brand_market_share_what_if: null<number>; 
  readonly market_average_price_what_if: null<number>; 
  readonly attribution_sales_what_if: null<number>; 
  readonly attribution_spend_what_if: null<number>; 
  readonly attribution_impressions_what_if: null<number>; 
  readonly attribution_clicks_what_if: null<number>; 
  readonly attribution_orders_what_if: null<number>; 
  readonly attribution_units_sold_what_if: null<number>; 
  readonly attribution_ctr_what_if: null<number>; 
  readonly attribution_cvr_what_if: null<number>; 
  readonly attribution_acos_what_if: null<number>; 
  readonly attribution_roas_what_if: null<number>; 
  readonly attribution_cpc_what_if: null<number>; 
  readonly attribution_cpm_what_if: null<number>
};

export type insightResponse = {
  readonly summary: string; 
  readonly date_start: string; 
  readonly date_end: string; 
  readonly asin: null<string>; 
  readonly agent: string
};

export type inventoryExecutiveSummaryResponseSchema = {
  readonly fba_in_stock_rate: null<number>; 
  readonly fbt_in_stock_rate: null<number>; 
  readonly three_pl_in_stock_rate: null<number>; 
  readonly storage_costs: null<number>; 
  readonly shipping_costs: null<number>; 
  readonly forecasting_accuracy: null<number>; 
  readonly inventory_turnover: null<number>; 
  readonly safety_stock: null<number>; 
  readonly doi_available: null<number>; 
  readonly total_doi: null<number>; 
  readonly estimated_stock_out_date: null<string>
};

export type marketIntelligenceExecutiveSummaryResponseSchema = {
  readonly market_total_sales: null<number>; 
  readonly brand_market_share: null<number>; 
  readonly market_average_price: null<number>; 
  readonly market_total_units_sold: null<number>; 
  readonly market_asin_count: null<number>; 
  readonly market_promotion_value: null<number>; 
  readonly market_promotion_count: null<number>; 
  readonly market_review_score: null<number>; 
  readonly market_pos: null<number>; 
  readonly market_ad_spend: null<number>
};

export type organicExecutiveSummaryResponseSchema = {
  readonly organic_sales: number; 
  readonly organic_impressions: null<number>; 
  readonly organic_ctr: null<number>; 
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
  readonly total_sales_diff_pct: null<number>; 
  readonly net_profit_diff_pct: null<number>; 
  readonly gross_profit_diff_pct: null<number>; 
  readonly roi_diff_pct: null<number>; 
  readonly goals: (undefined | Dict_t<string>[]); 
  readonly asin: null<string>
};

export type totalExecutiveSummaryResponseSchema = {
  readonly total_sales: null<number>; 
  readonly total_spend: null<number>; 
  readonly total_impressions: null<number>; 
  readonly ctr: null<number>; 
  readonly total_clicks: null<number>; 
  readonly cvr: null<number>; 
  readonly total_orders: null<number>; 
  readonly total_units_sold: null<number>; 
  readonly total_ntb_orders: null<number>; 
  readonly tacos: null<number>; 
  readonly mer: null<number>; 
  readonly lost_sales: null<number>
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
  readonly current_value: null<number>; 
  readonly percentage_change: number; 
  readonly target_value: null<number>
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
  readonly compare_value: null<Dict_t<string>>; 
  readonly compare_diff: null<Dict_t<string>>; 
  readonly compare_percent_diff: null<floatOrDict>
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
  readonly ad_ctr: null<number>; 
  readonly ad_clicks: number; 
  readonly ad_cvr: null<number>; 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: null<number>; 
  readonly roas: null<number>; 
  readonly cpc: null<number>; 
  readonly cpm: null<number>; 
  readonly time_in_budget: null<number>; 
  readonly ad_tos_is: null<number>; 
  readonly ads_non_optimal_spend: null<number>; 
  readonly real: adsExecutiveSummaryResponseSchema; 
  readonly forecasted: adsExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: adsExecutiveSummaryResponseSchema; 
  readonly compare_value: null<adsExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<adsExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: null<adsExecutiveSummaryResponseSchema>; 
  readonly diff: null<adsExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<adsExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<adsExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type attributionExecutiveSummaryWithForecastBreakdown = {
  readonly attribution_sales: null<number>; 
  readonly attribution_spend: null<number>; 
  readonly attribution_impressions: null<number>; 
  readonly attribution_ctr: null<number>; 
  readonly attribution_clicks: null<number>; 
  readonly attribution_cvr: null<number>; 
  readonly attribution_orders: null<number>; 
  readonly attribution_units_sold: null<number>; 
  readonly attribution_acos: null<number>; 
  readonly attribution_roas: null<number>; 
  readonly attribution_cpc: null<number>; 
  readonly attribution_cpm: null<number>; 
  readonly real: attributionExecutiveSummaryResponseSchema; 
  readonly forecasted: attributionExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: attributionExecutiveSummaryResponseSchema; 
  readonly compare_value: null<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: null<attributionExecutiveSummaryResponseSchema>; 
  readonly diff: null<attributionExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<attributionExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type cFOExecutiveSummaryWithForecastBreakdown = {
  readonly available_capital: null<number>; 
  readonly frozen_capital: null<number>; 
  readonly borrowed_capital: null<number>; 
  readonly gross_profit: null<number>; 
  readonly gross_margin: null<number>; 
  readonly contribution_profit: null<number>; 
  readonly contribution_margin: null<number>; 
  readonly net_profit: null<number>; 
  readonly net_margin: null<number>; 
  readonly opex: null<number>; 
  readonly roi: null<number>; 
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
  readonly compare_value: null<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: null<cFOExecutiveSummaryResponseSchema>; 
  readonly diff: null<cFOExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<cFOExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type tierLevelForecastParams = {
  readonly impressions_what_if: null<number>; 
  readonly clicks_what_if: null<number>; 
  readonly orders_what_if: null<number>; 
  readonly units_sold_what_if: null<number>; 
  readonly sales_what_if: null<number>; 
  readonly ad_spend_what_if: null<number>; 
  readonly ad_impressions_what_if: null<number>; 
  readonly ad_clicks_what_if: null<number>; 
  readonly ad_orders_what_if: null<number>; 
  readonly ad_sales_what_if: null<number>; 
  readonly ad_units_sold_what_if: null<number>; 
  readonly ad_ctr_what_if: null<number>; 
  readonly ad_cvr_what_if: null<number>; 
  readonly cpc_what_if: null<number>; 
  readonly cpm_what_if: null<number>; 
  readonly organic_impressions_what_if: null<number>; 
  readonly organic_clicks_what_if: null<number>; 
  readonly organic_orders_what_if: null<number>; 
  readonly organic_sales_what_if: null<number>; 
  readonly organic_units_sold_what_if: null<number>; 
  readonly total_sales_what_if: null<number>; 
  readonly total_spend_what_if: null<number>; 
  readonly total_impressions_what_if: null<number>; 
  readonly total_clicks_what_if: null<number>; 
  readonly total_orders_what_if: null<number>; 
  readonly total_units_sold_what_if: null<number>; 
  readonly lost_sales_what_if: null<number>; 
  readonly ctr_what_if: null<number>; 
  readonly cvr_what_if: null<number>; 
  readonly acos_what_if: null<number>; 
  readonly tacos_what_if: null<number>; 
  readonly roas_what_if: null<number>; 
  readonly mer_what_if: null<number>; 
  readonly aov_what_if: null<number>; 
  readonly gross_profit_what_if: null<number>; 
  readonly gross_margin_what_if: null<number>; 
  readonly contribution_profit_what_if: null<number>; 
  readonly contribution_margin_what_if: null<number>; 
  readonly net_profit_what_if: null<number>; 
  readonly net_margin_what_if: null<number>; 
  readonly roi_what_if: null<number>; 
  readonly available_capital_what_if: null<number>; 
  readonly frozen_capital_what_if: null<number>; 
  readonly ebitda_what_if: null<number>; 
  readonly cogs_what_if: null<number>; 
  readonly cost_of_goods_sold_what_if: null<number>; 
  readonly amazon_fees_what_if: null<number>; 
  readonly opex_what_if: null<number>; 
  readonly discount_what_if: null<number>; 
  readonly coupon_what_if: null<number>; 
  readonly subscribe_save_what_if: null<number>; 
  readonly text_score_what_if: null<number>; 
  readonly image_score_what_if: null<number>; 
  readonly video_score_what_if: null<number>; 
  readonly a_plus_score_what_if: null<number>; 
  readonly fba_in_stock_rate_what_if: null<number>; 
  readonly inventory_turnover_what_if: null<number>; 
  readonly safety_stock_what_if: null<number>; 
  readonly storage_costs_what_if: null<number>; 
  readonly shipping_costs_what_if: null<number>; 
  readonly market_total_sales_what_if: null<number>; 
  readonly brand_market_share_what_if: null<number>; 
  readonly market_average_price_what_if: null<number>; 
  readonly attribution_sales_what_if: null<number>; 
  readonly attribution_spend_what_if: null<number>; 
  readonly attribution_impressions_what_if: null<number>; 
  readonly attribution_clicks_what_if: null<number>; 
  readonly attribution_orders_what_if: null<number>; 
  readonly attribution_units_sold_what_if: null<number>; 
  readonly attribution_ctr_what_if: null<number>; 
  readonly attribution_cvr_what_if: null<number>; 
  readonly attribution_acos_what_if: null<number>; 
  readonly attribution_roas_what_if: null<number>; 
  readonly attribution_cpc_what_if: null<number>; 
  readonly attribution_cpm_what_if: null<number>; 
  readonly no_sales: null<forecastParams>; 
  readonly poor: null<forecastParams>; 
  readonly mid: null<forecastParams>; 
  readonly good: null<forecastParams>
};

export type getV1MathInsightsTotalResponse = insightResponse;

export type getV1MathInsightsMarketResponse = insightResponse;

export type getV1MathInsightsAdsResponse = insightResponse;

export type getV1MathInsightsOrganicResponse = insightResponse;

export type getV1MathInsightsAttributionResponse = insightResponse;

export type getV1MathInsightsCfoResponse = insightResponse;

export type getV1MathInsightsInventoryResponse = insightResponse;

export type inventoryExecutiveSummaryWithForecastBreakdown = {
  readonly fba_in_stock_rate: null<number>; 
  readonly fbt_in_stock_rate: null<number>; 
  readonly three_pl_in_stock_rate: null<number>; 
  readonly storage_costs: null<number>; 
  readonly shipping_costs: null<number>; 
  readonly forecasting_accuracy: null<number>; 
  readonly inventory_turnover: null<number>; 
  readonly safety_stock: null<number>; 
  readonly doi_available: null<number>; 
  readonly total_doi: null<number>; 
  readonly estimated_stock_out_date: null<string>; 
  readonly real: inventoryExecutiveSummaryResponseSchema; 
  readonly forecasted: inventoryExecutiveSummaryResponseSchema
};

export type timelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: inventoryExecutiveSummaryResponseSchema; 
  readonly compare_value: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly diff: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<inventoryExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  readonly market_total_sales: null<number>; 
  readonly brand_market_share: null<number>; 
  readonly market_average_price: null<number>; 
  readonly market_total_units_sold: null<number>; 
  readonly market_asin_count: null<number>; 
  readonly market_promotion_value: null<number>; 
  readonly market_promotion_count: null<number>; 
  readonly market_review_score: null<number>; 
  readonly market_pos: null<number>; 
  readonly market_ad_spend: null<number>; 
  readonly real: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly forecasted: marketIntelligenceExecutiveSummaryResponseSchema
};

export type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly compare_value: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly diff: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<marketIntelligenceExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type organicExecutiveSummaryWithForecastBreakdown = {
  readonly organic_sales: number; 
  readonly organic_impressions: null<number>; 
  readonly organic_ctr: null<number>; 
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
  readonly projected: null<organicExecutiveSummaryResponseSchema>; 
  readonly diff: null<organicExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<organicExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<organicExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type getV1MathInsightsStrategicPlanResponse = strategicPlanResponse;

export type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: totalExecutiveSummaryResponseSchema; 
  readonly compare_value: null<totalExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<totalExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type totalExecutiveSummaryWithForecastBreakdown = {
  readonly total_sales: null<number>; 
  readonly total_spend: null<number>; 
  readonly total_impressions: null<number>; 
  readonly ctr: null<number>; 
  readonly total_clicks: null<number>; 
  readonly cvr: null<number>; 
  readonly total_orders: null<number>; 
  readonly total_units_sold: null<number>; 
  readonly total_ntb_orders: null<number>; 
  readonly tacos: null<number>; 
  readonly mer: null<number>; 
  readonly lost_sales: null<number>; 
  readonly real: totalExecutiveSummaryResponseSchema; 
  readonly forecasted: totalExecutiveSummaryResponseSchema
};

export type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: null<totalExecutiveSummaryResponseSchema>; 
  readonly diff: null<totalExecutiveSummaryResponseSchema>; 
  readonly percent_diff: null<floatOrDict>; 
  readonly compare_value: null<totalExecutiveSummaryResponseSchema>; 
  readonly compare_diff: null<totalExecutiveSummaryResponseSchema>; 
  readonly compare_percent_diff: null<floatOrDict>
};

export type inventoryMetricsResponse = { readonly daily_metrics: dailyInventoryMetrics[]; readonly total_metrics: totalInventoryMetrics };

export type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: adsExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: attributionExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: cFOExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: inventoryExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly baseline: organicExecutiveSummaryResponseSchema; 
  readonly projected: organicExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: totalExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<null<number>>; 
  readonly percent_diff: Dict_t<null<number>>; 
  readonly whatif_applied: Dict_t<whatifAppliedEntry>; 
  readonly model_info: whatifModelInfo; 
  readonly warnings: null<string[]>
};

export type timelineResponse_dict_ = {
  readonly data: timelineDataPoint_dict_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type hTTPValidationError = { readonly detail: (undefined | validationError[]) };

export type timelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: null<string>
};

export type getV1MathInventoryMetricsResponse = 
    { _tag: "InventoryMetricsResponse"; readonly daily_metrics: dailyInventoryMetrics[]; readonly total_metrics: totalInventoryMetrics }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_dict_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: Dict_t<string>; readonly compare_value: null<Dict_t<string>>; readonly compare_diff: null<Dict_t<string>>; readonly compare_percent_diff: null<floatOrDict> };

export type getV1MathOrganicExecutiveSummaryResponse = 
    { _tag: "OrganicExecutiveSummaryResponseSchema"; readonly organic_sales: number; readonly organic_impressions: null<number>; readonly organic_ctr: null<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number }
  | { _tag: "OrganicExecutiveSummaryWithForecastBreakdown"; readonly organic_sales: number; readonly organic_impressions: null<number>; readonly organic_ctr: null<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number; readonly real: organicExecutiveSummaryResponseSchema; readonly forecasted: organicExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_dict_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: Dict_t<string>; readonly compare_value: null<Dict_t<string>>; readonly compare_diff: null<Dict_t<string>>; readonly compare_percent_diff: null<floatOrDict> };

export type getV1MathAdsExecutiveSummaryResponse = 
    { _tag: "AdsExecutiveSummaryResponseSchema"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: null<number>; readonly ad_clicks: number; readonly ad_cvr: null<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: null<number>; readonly roas: null<number>; readonly cpc: null<number>; readonly cpm: null<number>; readonly time_in_budget: null<number>; readonly ad_tos_is: null<number>; readonly ads_non_optimal_spend: null<number> }
  | { _tag: "AdsExecutiveSummaryWithForecastBreakdown"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: null<number>; readonly ad_clicks: number; readonly ad_cvr: null<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: null<number>; readonly roas: null<number>; readonly cpc: null<number>; readonly cpm: null<number>; readonly time_in_budget: null<number>; readonly ad_tos_is: null<number>; readonly ads_non_optimal_spend: null<number>; readonly real: adsExecutiveSummaryResponseSchema; readonly forecasted: adsExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: adsExecutiveSummaryResponseSchema; readonly compare_value: null<adsExecutiveSummaryResponseSchema>; readonly compare_diff: null<adsExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathAdsExecutiveSummaryResponse = 
    { _tag: "AdsExecutiveSummaryResponseSchema"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: null<number>; readonly ad_clicks: number; readonly ad_cvr: null<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: null<number>; readonly roas: null<number>; readonly cpc: null<number>; readonly cpm: null<number>; readonly time_in_budget: null<number>; readonly ad_tos_is: null<number>; readonly ads_non_optimal_spend: null<number> }
  | { _tag: "AdsExecutiveSummaryWithForecastBreakdown"; readonly ad_sales: number; readonly ad_spend: number; readonly ad_impressions: number; readonly ad_ctr: null<number>; readonly ad_clicks: number; readonly ad_cvr: null<number>; readonly ad_orders: number; readonly ad_units_sold: number; readonly acos: null<number>; readonly roas: null<number>; readonly cpc: null<number>; readonly cpm: null<number>; readonly time_in_budget: null<number>; readonly ad_tos_is: null<number>; readonly ads_non_optimal_spend: null<number>; readonly real: adsExecutiveSummaryResponseSchema; readonly forecasted: adsExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: adsExecutiveSummaryResponseSchema; readonly projected: adsExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type getV1MathAttributionExecutiveSummaryResponse = 
    { _tag: "AttributionExecutiveSummaryResponseSchema"; readonly attribution_sales: null<number>; readonly attribution_spend: null<number>; readonly attribution_impressions: null<number>; readonly attribution_ctr: null<number>; readonly attribution_clicks: null<number>; readonly attribution_cvr: null<number>; readonly attribution_orders: null<number>; readonly attribution_units_sold: null<number>; readonly attribution_acos: null<number>; readonly attribution_roas: null<number>; readonly attribution_cpc: null<number>; readonly attribution_cpm: null<number> }
  | { _tag: "AttributionExecutiveSummaryWithForecastBreakdown"; readonly attribution_sales: null<number>; readonly attribution_spend: null<number>; readonly attribution_impressions: null<number>; readonly attribution_ctr: null<number>; readonly attribution_clicks: null<number>; readonly attribution_cvr: null<number>; readonly attribution_orders: null<number>; readonly attribution_units_sold: null<number>; readonly attribution_acos: null<number>; readonly attribution_roas: null<number>; readonly attribution_cpc: null<number>; readonly attribution_cpm: null<number>; readonly real: attributionExecutiveSummaryResponseSchema; readonly forecasted: attributionExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: attributionExecutiveSummaryResponseSchema; readonly compare_value: null<attributionExecutiveSummaryResponseSchema>; readonly compare_diff: null<attributionExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathAttributionExecutiveSummaryResponse = 
    { _tag: "AttributionExecutiveSummaryResponseSchema"; readonly attribution_sales: null<number>; readonly attribution_spend: null<number>; readonly attribution_impressions: null<number>; readonly attribution_ctr: null<number>; readonly attribution_clicks: null<number>; readonly attribution_cvr: null<number>; readonly attribution_orders: null<number>; readonly attribution_units_sold: null<number>; readonly attribution_acos: null<number>; readonly attribution_roas: null<number>; readonly attribution_cpc: null<number>; readonly attribution_cpm: null<number> }
  | { _tag: "AttributionExecutiveSummaryWithForecastBreakdown"; readonly attribution_sales: null<number>; readonly attribution_spend: null<number>; readonly attribution_impressions: null<number>; readonly attribution_ctr: null<number>; readonly attribution_clicks: null<number>; readonly attribution_cvr: null<number>; readonly attribution_orders: null<number>; readonly attribution_units_sold: null<number>; readonly attribution_acos: null<number>; readonly attribution_roas: null<number>; readonly attribution_cpc: null<number>; readonly attribution_cpm: null<number>; readonly real: attributionExecutiveSummaryResponseSchema; readonly forecasted: attributionExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: attributionExecutiveSummaryResponseSchema; readonly projected: attributionExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type getV1MathCfoExecutiveSummaryResponse = 
    { _tag: "CFOExecutiveSummaryResponseSchema"; readonly available_capital: null<number>; readonly frozen_capital: null<number>; readonly borrowed_capital: null<number>; readonly gross_profit: null<number>; readonly gross_margin: null<number>; readonly contribution_profit: null<number>; readonly contribution_margin: null<number>; readonly net_profit: null<number>; readonly net_margin: null<number>; readonly opex: null<number>; readonly roi: null<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number }
  | { _tag: "CFOExecutiveSummaryWithForecastBreakdown"; readonly available_capital: null<number>; readonly frozen_capital: null<number>; readonly borrowed_capital: null<number>; readonly gross_profit: null<number>; readonly gross_margin: null<number>; readonly contribution_profit: null<number>; readonly contribution_margin: null<number>; readonly net_profit: null<number>; readonly net_margin: null<number>; readonly opex: null<number>; readonly roi: null<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number; readonly real: cFOExecutiveSummaryResponseSchema; readonly forecasted: cFOExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: cFOExecutiveSummaryResponseSchema; readonly compare_value: null<cFOExecutiveSummaryResponseSchema>; readonly compare_diff: null<cFOExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathCfoExecutiveSummaryResponse = 
    { _tag: "CFOExecutiveSummaryResponseSchema"; readonly available_capital: null<number>; readonly frozen_capital: null<number>; readonly borrowed_capital: null<number>; readonly gross_profit: null<number>; readonly gross_margin: null<number>; readonly contribution_profit: null<number>; readonly contribution_margin: null<number>; readonly net_profit: null<number>; readonly net_margin: null<number>; readonly opex: null<number>; readonly roi: null<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number }
  | { _tag: "CFOExecutiveSummaryWithForecastBreakdown"; readonly available_capital: null<number>; readonly frozen_capital: null<number>; readonly borrowed_capital: null<number>; readonly gross_profit: null<number>; readonly gross_margin: null<number>; readonly contribution_profit: null<number>; readonly contribution_margin: null<number>; readonly net_profit: null<number>; readonly net_margin: null<number>; readonly opex: null<number>; readonly roi: null<number>; readonly cost_of_goods_sold: number; readonly amazon_fees: number; readonly real: cFOExecutiveSummaryResponseSchema; readonly forecasted: cFOExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: cFOExecutiveSummaryResponseSchema; readonly projected: cFOExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type getV1MathInventoryMetricsExecutiveSummaryResponse = 
    { _tag: "InventoryExecutiveSummaryResponseSchema"; readonly fba_in_stock_rate: null<number>; readonly fbt_in_stock_rate: null<number>; readonly three_pl_in_stock_rate: null<number>; readonly storage_costs: null<number>; readonly shipping_costs: null<number>; readonly forecasting_accuracy: null<number>; readonly inventory_turnover: null<number>; readonly safety_stock: null<number>; readonly doi_available: null<number>; readonly total_doi: null<number>; readonly estimated_stock_out_date: null<string> }
  | { _tag: "InventoryExecutiveSummaryWithForecastBreakdown"; readonly fba_in_stock_rate: null<number>; readonly fbt_in_stock_rate: null<number>; readonly three_pl_in_stock_rate: null<number>; readonly storage_costs: null<number>; readonly shipping_costs: null<number>; readonly forecasting_accuracy: null<number>; readonly inventory_turnover: null<number>; readonly safety_stock: null<number>; readonly doi_available: null<number>; readonly total_doi: null<number>; readonly estimated_stock_out_date: null<string>; readonly real: inventoryExecutiveSummaryResponseSchema; readonly forecasted: inventoryExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: inventoryExecutiveSummaryResponseSchema; readonly compare_value: null<inventoryExecutiveSummaryResponseSchema>; readonly compare_diff: null<inventoryExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathInventoryMetricsExecutiveSummaryResponse = 
    { _tag: "InventoryExecutiveSummaryResponseSchema"; readonly fba_in_stock_rate: null<number>; readonly fbt_in_stock_rate: null<number>; readonly three_pl_in_stock_rate: null<number>; readonly storage_costs: null<number>; readonly shipping_costs: null<number>; readonly forecasting_accuracy: null<number>; readonly inventory_turnover: null<number>; readonly safety_stock: null<number>; readonly doi_available: null<number>; readonly total_doi: null<number>; readonly estimated_stock_out_date: null<string> }
  | { _tag: "InventoryExecutiveSummaryWithForecastBreakdown"; readonly fba_in_stock_rate: null<number>; readonly fbt_in_stock_rate: null<number>; readonly three_pl_in_stock_rate: null<number>; readonly storage_costs: null<number>; readonly shipping_costs: null<number>; readonly forecasting_accuracy: null<number>; readonly inventory_turnover: null<number>; readonly safety_stock: null<number>; readonly doi_available: null<number>; readonly total_doi: null<number>; readonly estimated_stock_out_date: null<string>; readonly real: inventoryExecutiveSummaryResponseSchema; readonly forecasted: inventoryExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: inventoryExecutiveSummaryResponseSchema; readonly projected: inventoryExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type getV1MathMarketIntelligenceExecutiveSummaryResponse = 
    { _tag: "MarketIntelligenceExecutiveSummaryResponseSchema"; readonly market_total_sales: null<number>; readonly brand_market_share: null<number>; readonly market_average_price: null<number>; readonly market_total_units_sold: null<number>; readonly market_asin_count: null<number>; readonly market_promotion_value: null<number>; readonly market_promotion_count: null<number>; readonly market_review_score: null<number>; readonly market_pos: null<number>; readonly market_ad_spend: null<number> }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: marketIntelligenceExecutiveSummaryResponseSchema; readonly compare_value: null<marketIntelligenceExecutiveSummaryResponseSchema>; readonly compare_diff: null<marketIntelligenceExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathMarketIntelligenceExecutiveSummaryResponse = 
    { _tag: "MarketIntelligenceExecutiveSummaryResponseSchema"; readonly market_total_sales: null<number>; readonly brand_market_share: null<number>; readonly market_average_price: null<number>; readonly market_total_units_sold: null<number>; readonly market_asin_count: null<number>; readonly market_promotion_value: null<number>; readonly market_promotion_count: null<number>; readonly market_review_score: null<number>; readonly market_pos: null<number>; readonly market_ad_spend: null<number> }
  | { _tag: "MarketIntelligenceExecutiveSummaryWithForecastBreakdown"; readonly market_total_sales: null<number>; readonly brand_market_share: null<number>; readonly market_average_price: null<number>; readonly market_total_units_sold: null<number>; readonly market_asin_count: null<number>; readonly market_promotion_value: null<number>; readonly market_promotion_count: null<number>; readonly market_review_score: null<number>; readonly market_pos: null<number>; readonly market_ad_spend: null<number>; readonly real: marketIntelligenceExecutiveSummaryResponseSchema; readonly forecasted: marketIntelligenceExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; readonly projected: marketIntelligenceExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type postV1MathOrganicExecutiveSummaryResponse = 
    { _tag: "OrganicExecutiveSummaryResponseSchema"; readonly organic_sales: number; readonly organic_impressions: null<number>; readonly organic_ctr: null<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number }
  | { _tag: "OrganicExecutiveSummaryWithForecastBreakdown"; readonly organic_sales: number; readonly organic_impressions: null<number>; readonly organic_ctr: null<number>; readonly organic_clicks: number; readonly organic_cvr: number; readonly organic_orders: number; readonly organic_units_sold: number; readonly real: organicExecutiveSummaryResponseSchema; readonly forecasted: organicExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: organicExecutiveSummaryResponseSchema; readonly projected: organicExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };

export type getV1MathTotalExecutiveSummaryResponse = 
    { _tag: "TotalExecutiveSummaryResponseSchema"; readonly total_sales: null<number>; readonly total_spend: null<number>; readonly total_impressions: null<number>; readonly ctr: null<number>; readonly total_clicks: null<number>; readonly cvr: null<number>; readonly total_orders: null<number>; readonly total_units_sold: null<number>; readonly total_ntb_orders: null<number>; readonly tacos: null<number>; readonly mer: null<number>; readonly lost_sales: null<number> }
  | { _tag: "TotalExecutiveSummaryWithForecastBreakdown"; readonly total_sales: null<number>; readonly total_spend: null<number>; readonly total_impressions: null<number>; readonly ctr: null<number>; readonly total_clicks: null<number>; readonly cvr: null<number>; readonly total_orders: null<number>; readonly total_units_sold: null<number>; readonly total_ntb_orders: null<number>; readonly tacos: null<number>; readonly mer: null<number>; readonly lost_sales: null<number>; readonly real: totalExecutiveSummaryResponseSchema; readonly forecasted: totalExecutiveSummaryResponseSchema }
  | { _tag: "TimelineResponse"; readonly data: timelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> }
  | { _tag: "TimelineDataPoint"; readonly period_start: string; readonly period_end: string; readonly is_forecast: boolean; readonly value: totalExecutiveSummaryResponseSchema; readonly compare_value: null<totalExecutiveSummaryResponseSchema>; readonly compare_diff: null<totalExecutiveSummaryResponseSchema>; readonly compare_percent_diff: null<floatOrDict> };

export type postV1MathTotalExecutiveSummaryResponse = 
    { _tag: "TotalExecutiveSummaryResponseSchema"; readonly total_sales: null<number>; readonly total_spend: null<number>; readonly total_impressions: null<number>; readonly ctr: null<number>; readonly total_clicks: null<number>; readonly cvr: null<number>; readonly total_orders: null<number>; readonly total_units_sold: null<number>; readonly total_ntb_orders: null<number>; readonly tacos: null<number>; readonly mer: null<number>; readonly lost_sales: null<number> }
  | { _tag: "TotalExecutiveSummaryWithForecastBreakdown"; readonly total_sales: null<number>; readonly total_spend: null<number>; readonly total_impressions: null<number>; readonly ctr: null<number>; readonly total_clicks: null<number>; readonly cvr: null<number>; readonly total_orders: null<number>; readonly total_units_sold: null<number>; readonly total_ntb_orders: null<number>; readonly tacos: null<number>; readonly mer: null<number>; readonly lost_sales: null<number>; readonly real: totalExecutiveSummaryResponseSchema; readonly forecasted: totalExecutiveSummaryResponseSchema }
  | { _tag: "WhatifResponse"; readonly baseline: totalExecutiveSummaryResponseSchema; readonly projected: totalExecutiveSummaryResponseSchema; readonly diff: Dict_t<null<number>>; readonly percent_diff: Dict_t<null<number>>; readonly whatif_applied: Dict_t<whatifAppliedEntry>; readonly model_info: whatifModelInfo; readonly warnings: null<string[]> }
  | { _tag: "WhatifTimelineResponse"; readonly data: whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; readonly period_start: string; readonly period_end: string; readonly period: null<string> };
