/* TypeScript file generated from Generated.res by genType. */

/* eslint-disable */
/* tslint:disable */

import type {t as Dict_t} from './Dict.gen';

export type timelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineDataPoint_dict__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type validationError_loc = 
    { _tag: "String"; _0: string }
  | { _tag: "Int"; _0: number };

export type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff = 
    { _tag: "Float"; _0: number }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type adsExecutiveSummaryResponseSchema = {
  readonly ad_sales: number; 
  readonly ad_spend: number; 
  readonly ad_impressions: number; 
  readonly ad_ctr: (undefined | number); 
  readonly ad_clicks: number; 
  readonly ad_cvr: (undefined | number); 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: (undefined | number); 
  readonly roas: (undefined | number); 
  readonly cpc: (undefined | number); 
  readonly cpm: (undefined | number); 
  readonly time_in_budget: (undefined | number); 
  readonly ad_tos_is: (undefined | number); 
  readonly ads_non_optimal_spend: (undefined | number)
};

export type attributionExecutiveSummaryResponseSchema = {
  readonly attribution_sales: (undefined | number); 
  readonly attribution_spend: (undefined | number); 
  readonly attribution_impressions: (undefined | number); 
  readonly attribution_ctr: (undefined | number); 
  readonly attribution_clicks: (undefined | number); 
  readonly attribution_cvr: (undefined | number); 
  readonly attribution_orders: (undefined | number); 
  readonly attribution_units_sold: (undefined | number); 
  readonly attribution_acos: (undefined | number); 
  readonly attribution_roas: (undefined | number); 
  readonly attribution_cpc: (undefined | number); 
  readonly attribution_cpm: (undefined | number)
};

export type cFOExecutiveSummaryResponseSchema = {
  readonly available_capital: (undefined | number); 
  readonly frozen_capital: (undefined | number); 
  readonly borrowed_capital: (undefined | number); 
  readonly gross_profit: (undefined | number); 
  readonly gross_margin: (undefined | number); 
  readonly contribution_profit: (undefined | number); 
  readonly contribution_margin: (undefined | number); 
  readonly net_profit: (undefined | number); 
  readonly net_margin: (undefined | number); 
  readonly opex: (undefined | number); 
  readonly roi: (undefined | number); 
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
  readonly impressions_what_if: (undefined | number); 
  readonly clicks_what_if: (undefined | number); 
  readonly orders_what_if: (undefined | number); 
  readonly units_sold_what_if: (undefined | number); 
  readonly sales_what_if: (undefined | number); 
  readonly ad_spend_what_if: (undefined | number); 
  readonly ad_impressions_what_if: (undefined | number); 
  readonly ad_clicks_what_if: (undefined | number); 
  readonly ad_orders_what_if: (undefined | number); 
  readonly ad_sales_what_if: (undefined | number); 
  readonly ad_units_sold_what_if: (undefined | number); 
  readonly ad_ctr_what_if: (undefined | number); 
  readonly ad_cvr_what_if: (undefined | number); 
  readonly cpc_what_if: (undefined | number); 
  readonly cpm_what_if: (undefined | number); 
  readonly organic_impressions_what_if: (undefined | number); 
  readonly organic_clicks_what_if: (undefined | number); 
  readonly organic_orders_what_if: (undefined | number); 
  readonly organic_sales_what_if: (undefined | number); 
  readonly organic_units_sold_what_if: (undefined | number); 
  readonly total_sales_what_if: (undefined | number); 
  readonly total_spend_what_if: (undefined | number); 
  readonly total_impressions_what_if: (undefined | number); 
  readonly total_clicks_what_if: (undefined | number); 
  readonly total_orders_what_if: (undefined | number); 
  readonly total_units_sold_what_if: (undefined | number); 
  readonly lost_sales_what_if: (undefined | number); 
  readonly ctr_what_if: (undefined | number); 
  readonly cvr_what_if: (undefined | number); 
  readonly acos_what_if: (undefined | number); 
  readonly tacos_what_if: (undefined | number); 
  readonly roas_what_if: (undefined | number); 
  readonly mer_what_if: (undefined | number); 
  readonly aov_what_if: (undefined | number); 
  readonly gross_profit_what_if: (undefined | number); 
  readonly gross_margin_what_if: (undefined | number); 
  readonly contribution_profit_what_if: (undefined | number); 
  readonly contribution_margin_what_if: (undefined | number); 
  readonly net_profit_what_if: (undefined | number); 
  readonly net_margin_what_if: (undefined | number); 
  readonly roi_what_if: (undefined | number); 
  readonly available_capital_what_if: (undefined | number); 
  readonly frozen_capital_what_if: (undefined | number); 
  readonly ebitda_what_if: (undefined | number); 
  readonly cogs_what_if: (undefined | number); 
  readonly cost_of_goods_sold_what_if: (undefined | number); 
  readonly amazon_fees_what_if: (undefined | number); 
  readonly opex_what_if: (undefined | number); 
  readonly discount_what_if: (undefined | number); 
  readonly coupon_what_if: (undefined | number); 
  readonly subscribe_save_what_if: (undefined | number); 
  readonly text_score_what_if: (undefined | number); 
  readonly image_score_what_if: (undefined | number); 
  readonly video_score_what_if: (undefined | number); 
  readonly a_plus_score_what_if: (undefined | number); 
  readonly fba_in_stock_rate_what_if: (undefined | number); 
  readonly inventory_turnover_what_if: (undefined | number); 
  readonly safety_stock_what_if: (undefined | number); 
  readonly storage_costs_what_if: (undefined | number); 
  readonly shipping_costs_what_if: (undefined | number); 
  readonly market_total_sales_what_if: (undefined | number); 
  readonly brand_market_share_what_if: (undefined | number); 
  readonly market_average_price_what_if: (undefined | number); 
  readonly attribution_sales_what_if: (undefined | number); 
  readonly attribution_spend_what_if: (undefined | number); 
  readonly attribution_impressions_what_if: (undefined | number); 
  readonly attribution_clicks_what_if: (undefined | number); 
  readonly attribution_orders_what_if: (undefined | number); 
  readonly attribution_units_sold_what_if: (undefined | number); 
  readonly attribution_ctr_what_if: (undefined | number); 
  readonly attribution_cvr_what_if: (undefined | number); 
  readonly attribution_acos_what_if: (undefined | number); 
  readonly attribution_roas_what_if: (undefined | number); 
  readonly attribution_cpc_what_if: (undefined | number); 
  readonly attribution_cpm_what_if: (undefined | number)
};

export type insightResponse = {
  readonly summary: string; 
  readonly date_start: string; 
  readonly date_end: string; 
  readonly asin: (undefined | string); 
  readonly agent: string
};

export type inventoryExecutiveSummaryResponseSchema = {
  readonly fba_in_stock_rate: (undefined | number); 
  readonly fbt_in_stock_rate: (undefined | number); 
  readonly three_pl_in_stock_rate: (undefined | number); 
  readonly storage_costs: (undefined | number); 
  readonly shipping_costs: (undefined | number); 
  readonly forecasting_accuracy: (undefined | number); 
  readonly inventory_turnover: (undefined | number); 
  readonly safety_stock: (undefined | number); 
  readonly doi_available: (undefined | number); 
  readonly total_doi: (undefined | number); 
  readonly estimated_stock_out_date: (undefined | string)
};

export type marketIntelligenceExecutiveSummaryResponseSchema = {
  readonly market_total_sales: (undefined | number); 
  readonly brand_market_share: (undefined | number); 
  readonly market_average_price: (undefined | number); 
  readonly market_total_units_sold: (undefined | number); 
  readonly market_asin_count: (undefined | number); 
  readonly market_promotion_value: (undefined | number); 
  readonly market_promotion_count: (undefined | number); 
  readonly market_review_score: (undefined | number); 
  readonly market_pos: (undefined | number); 
  readonly market_ad_spend: (undefined | number)
};

export type organicExecutiveSummaryResponseSchema = {
  readonly organic_sales: number; 
  readonly organic_impressions: (undefined | number); 
  readonly organic_ctr: (undefined | number); 
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
  readonly total_sales_diff_pct: (undefined | number); 
  readonly net_profit_diff_pct: (undefined | number); 
  readonly gross_profit_diff_pct: (undefined | number); 
  readonly roi_diff_pct: (undefined | number); 
  readonly goals: (undefined | Dict_t<string>[]); 
  readonly asin: (undefined | string)
};

export type totalExecutiveSummaryResponseSchema = {
  readonly total_sales: (undefined | number); 
  readonly total_spend: (undefined | number); 
  readonly total_impressions: (undefined | number); 
  readonly ctr: (undefined | number); 
  readonly total_clicks: (undefined | number); 
  readonly cvr: (undefined | number); 
  readonly total_orders: (undefined | number); 
  readonly total_units_sold: (undefined | number); 
  readonly total_ntb_orders: (undefined | number); 
  readonly tacos: (undefined | number); 
  readonly mer: (undefined | number); 
  readonly lost_sales: (undefined | number)
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
  readonly current_value: (undefined | number); 
  readonly percentage_change: number; 
  readonly target_value: (undefined | number)
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
  readonly compare_value: (undefined | Dict_t<string>); 
  readonly compare_diff: (undefined | Dict_t<string>); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_dict__compare_percent_diff)
};

export type validationError = {
  readonly loc: validationError_loc[]; 
  readonly msg: string; 
  readonly type: string
};

export type adsExecutiveSummaryWithForecastBreakdown = {
  readonly ad_sales: number; 
  readonly ad_spend: number; 
  readonly ad_impressions: number; 
  readonly ad_ctr: (undefined | number); 
  readonly ad_clicks: number; 
  readonly ad_cvr: (undefined | number); 
  readonly ad_orders: number; 
  readonly ad_units_sold: number; 
  readonly acos: (undefined | number); 
  readonly roas: (undefined | number); 
  readonly cpc: (undefined | number); 
  readonly cpm: (undefined | number); 
  readonly time_in_budget: (undefined | number); 
  readonly ad_tos_is: (undefined | number); 
  readonly ads_non_optimal_spend: (undefined | number); 
  readonly real: adsExecutiveSummaryResponseSchema; 
  readonly forecasted: adsExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: adsExecutiveSummaryResponseSchema; 
  readonly compare_value: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | adsExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type attributionExecutiveSummaryWithForecastBreakdown = {
  readonly attribution_sales: (undefined | number); 
  readonly attribution_spend: (undefined | number); 
  readonly attribution_impressions: (undefined | number); 
  readonly attribution_ctr: (undefined | number); 
  readonly attribution_clicks: (undefined | number); 
  readonly attribution_cvr: (undefined | number); 
  readonly attribution_orders: (undefined | number); 
  readonly attribution_units_sold: (undefined | number); 
  readonly attribution_acos: (undefined | number); 
  readonly attribution_roas: (undefined | number); 
  readonly attribution_cpc: (undefined | number); 
  readonly attribution_cpm: (undefined | number); 
  readonly real: attributionExecutiveSummaryResponseSchema; 
  readonly forecasted: attributionExecutiveSummaryResponseSchema
};

export type timelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: attributionExecutiveSummaryResponseSchema; 
  readonly compare_value: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | attributionExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type cFOExecutiveSummaryWithForecastBreakdown = {
  readonly available_capital: (undefined | number); 
  readonly frozen_capital: (undefined | number); 
  readonly borrowed_capital: (undefined | number); 
  readonly gross_profit: (undefined | number); 
  readonly gross_margin: (undefined | number); 
  readonly contribution_profit: (undefined | number); 
  readonly contribution_margin: (undefined | number); 
  readonly net_profit: (undefined | number); 
  readonly net_margin: (undefined | number); 
  readonly opex: (undefined | number); 
  readonly roi: (undefined | number); 
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
  readonly compare_value: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | cFOExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type tierLevelForecastParams = {
  readonly impressions_what_if: (undefined | number); 
  readonly clicks_what_if: (undefined | number); 
  readonly orders_what_if: (undefined | number); 
  readonly units_sold_what_if: (undefined | number); 
  readonly sales_what_if: (undefined | number); 
  readonly ad_spend_what_if: (undefined | number); 
  readonly ad_impressions_what_if: (undefined | number); 
  readonly ad_clicks_what_if: (undefined | number); 
  readonly ad_orders_what_if: (undefined | number); 
  readonly ad_sales_what_if: (undefined | number); 
  readonly ad_units_sold_what_if: (undefined | number); 
  readonly ad_ctr_what_if: (undefined | number); 
  readonly ad_cvr_what_if: (undefined | number); 
  readonly cpc_what_if: (undefined | number); 
  readonly cpm_what_if: (undefined | number); 
  readonly organic_impressions_what_if: (undefined | number); 
  readonly organic_clicks_what_if: (undefined | number); 
  readonly organic_orders_what_if: (undefined | number); 
  readonly organic_sales_what_if: (undefined | number); 
  readonly organic_units_sold_what_if: (undefined | number); 
  readonly total_sales_what_if: (undefined | number); 
  readonly total_spend_what_if: (undefined | number); 
  readonly total_impressions_what_if: (undefined | number); 
  readonly total_clicks_what_if: (undefined | number); 
  readonly total_orders_what_if: (undefined | number); 
  readonly total_units_sold_what_if: (undefined | number); 
  readonly lost_sales_what_if: (undefined | number); 
  readonly ctr_what_if: (undefined | number); 
  readonly cvr_what_if: (undefined | number); 
  readonly acos_what_if: (undefined | number); 
  readonly tacos_what_if: (undefined | number); 
  readonly roas_what_if: (undefined | number); 
  readonly mer_what_if: (undefined | number); 
  readonly aov_what_if: (undefined | number); 
  readonly gross_profit_what_if: (undefined | number); 
  readonly gross_margin_what_if: (undefined | number); 
  readonly contribution_profit_what_if: (undefined | number); 
  readonly contribution_margin_what_if: (undefined | number); 
  readonly net_profit_what_if: (undefined | number); 
  readonly net_margin_what_if: (undefined | number); 
  readonly roi_what_if: (undefined | number); 
  readonly available_capital_what_if: (undefined | number); 
  readonly frozen_capital_what_if: (undefined | number); 
  readonly ebitda_what_if: (undefined | number); 
  readonly cogs_what_if: (undefined | number); 
  readonly cost_of_goods_sold_what_if: (undefined | number); 
  readonly amazon_fees_what_if: (undefined | number); 
  readonly opex_what_if: (undefined | number); 
  readonly discount_what_if: (undefined | number); 
  readonly coupon_what_if: (undefined | number); 
  readonly subscribe_save_what_if: (undefined | number); 
  readonly text_score_what_if: (undefined | number); 
  readonly image_score_what_if: (undefined | number); 
  readonly video_score_what_if: (undefined | number); 
  readonly a_plus_score_what_if: (undefined | number); 
  readonly fba_in_stock_rate_what_if: (undefined | number); 
  readonly inventory_turnover_what_if: (undefined | number); 
  readonly safety_stock_what_if: (undefined | number); 
  readonly storage_costs_what_if: (undefined | number); 
  readonly shipping_costs_what_if: (undefined | number); 
  readonly market_total_sales_what_if: (undefined | number); 
  readonly brand_market_share_what_if: (undefined | number); 
  readonly market_average_price_what_if: (undefined | number); 
  readonly attribution_sales_what_if: (undefined | number); 
  readonly attribution_spend_what_if: (undefined | number); 
  readonly attribution_impressions_what_if: (undefined | number); 
  readonly attribution_clicks_what_if: (undefined | number); 
  readonly attribution_orders_what_if: (undefined | number); 
  readonly attribution_units_sold_what_if: (undefined | number); 
  readonly attribution_ctr_what_if: (undefined | number); 
  readonly attribution_cvr_what_if: (undefined | number); 
  readonly attribution_acos_what_if: (undefined | number); 
  readonly attribution_roas_what_if: (undefined | number); 
  readonly attribution_cpc_what_if: (undefined | number); 
  readonly attribution_cpm_what_if: (undefined | number); 
  readonly no_sales: (undefined | forecastParams); 
  readonly poor: (undefined | forecastParams); 
  readonly mid: (undefined | forecastParams); 
  readonly good: (undefined | forecastParams)
};

export type inventoryExecutiveSummaryWithForecastBreakdown = {
  readonly fba_in_stock_rate: (undefined | number); 
  readonly fbt_in_stock_rate: (undefined | number); 
  readonly three_pl_in_stock_rate: (undefined | number); 
  readonly storage_costs: (undefined | number); 
  readonly shipping_costs: (undefined | number); 
  readonly forecasting_accuracy: (undefined | number); 
  readonly inventory_turnover: (undefined | number); 
  readonly safety_stock: (undefined | number); 
  readonly doi_available: (undefined | number); 
  readonly total_doi: (undefined | number); 
  readonly estimated_stock_out_date: (undefined | string); 
  readonly real: inventoryExecutiveSummaryResponseSchema; 
  readonly forecasted: inventoryExecutiveSummaryResponseSchema
};

export type timelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: inventoryExecutiveSummaryResponseSchema; 
  readonly compare_value: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | inventoryExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type marketIntelligenceExecutiveSummaryWithForecastBreakdown = {
  readonly market_total_sales: (undefined | number); 
  readonly brand_market_share: (undefined | number); 
  readonly market_average_price: (undefined | number); 
  readonly market_total_units_sold: (undefined | number); 
  readonly market_asin_count: (undefined | number); 
  readonly market_promotion_value: (undefined | number); 
  readonly market_promotion_count: (undefined | number); 
  readonly market_review_score: (undefined | number); 
  readonly market_pos: (undefined | number); 
  readonly market_ad_spend: (undefined | number); 
  readonly real: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly forecasted: marketIntelligenceExecutiveSummaryResponseSchema
};

export type timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly compare_value: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | marketIntelligenceExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type organicExecutiveSummaryWithForecastBreakdown = {
  readonly organic_sales: number; 
  readonly organic_impressions: (undefined | number); 
  readonly organic_ctr: (undefined | number); 
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
  readonly projected: (undefined | organicExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | organicExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | organicExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | organicExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type timelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly value: totalExecutiveSummaryResponseSchema; 
  readonly compare_value: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | timelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type totalExecutiveSummaryWithForecastBreakdown = {
  readonly total_sales: (undefined | number); 
  readonly total_spend: (undefined | number); 
  readonly total_impressions: (undefined | number); 
  readonly ctr: (undefined | number); 
  readonly total_clicks: (undefined | number); 
  readonly cvr: (undefined | number); 
  readonly total_orders: (undefined | number); 
  readonly total_units_sold: (undefined | number); 
  readonly total_ntb_orders: (undefined | number); 
  readonly tacos: (undefined | number); 
  readonly mer: (undefined | number); 
  readonly lost_sales: (undefined | number); 
  readonly real: totalExecutiveSummaryResponseSchema; 
  readonly forecasted: totalExecutiveSummaryResponseSchema
};

export type whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_ = {
  readonly period_start: string; 
  readonly period_end: string; 
  readonly is_forecast: boolean; 
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly diff: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly percent_diff: (undefined | whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__percent_diff); 
  readonly compare_value: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly compare_diff: (undefined | totalExecutiveSummaryResponseSchema); 
  readonly compare_percent_diff: (undefined | whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema__compare_percent_diff)
};

export type inventoryMetricsResponse = { readonly daily_metrics: dailyInventoryMetrics[]; readonly total_metrics: totalInventoryMetrics };

export type whatifResponse_AdsExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_AttributionExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_CFOExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_InventoryExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_OrganicExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_TotalExecutiveSummaryResponseSchema__whatif_applied = 
    { _tag: "WhatifAppliedEntry"; _0: whatifAppliedEntry }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_AdsExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_AttributionExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_CFOExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_InventoryExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_OrganicExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type whatifResponse_TotalExecutiveSummaryResponseSchema__model_info = 
    { _tag: "WhatifModelInfo"; _0: whatifModelInfo }
  | { _tag: "Dict"; _0: Dict_t<string> };

export type timelineResponse_dict_ = {
  readonly data: timelineDataPoint_dict_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type hTTPValidationError = { readonly detail: (undefined | validationError[]) };

export type timelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AdsExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type timelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_AttributionExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type timelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_CFOExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type timelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_InventoryExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type timelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_MarketIntelligenceExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_OrganicExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type timelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: timelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifTimelineResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly data: whatifTimelineDataPoint_TotalExecutiveSummaryResponseSchema_[]; 
  readonly period_start: string; 
  readonly period_end: string; 
  readonly period: (undefined | string)
};

export type whatifResponse_AdsExecutiveSummaryResponseSchema_ = {
  readonly baseline: adsExecutiveSummaryResponseSchema; 
  readonly projected: adsExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_AdsExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_AdsExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_AttributionExecutiveSummaryResponseSchema_ = {
  readonly baseline: attributionExecutiveSummaryResponseSchema; 
  readonly projected: attributionExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_AttributionExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_AttributionExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_CFOExecutiveSummaryResponseSchema_ = {
  readonly baseline: cFOExecutiveSummaryResponseSchema; 
  readonly projected: cFOExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_CFOExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_CFOExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_InventoryExecutiveSummaryResponseSchema_ = {
  readonly baseline: inventoryExecutiveSummaryResponseSchema; 
  readonly projected: inventoryExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_InventoryExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_InventoryExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema_ = {
  readonly baseline: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly projected: marketIntelligenceExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_MarketIntelligenceExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_OrganicExecutiveSummaryResponseSchema_ = {
  readonly baseline: organicExecutiveSummaryResponseSchema; 
  readonly projected: organicExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_OrganicExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_OrganicExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};

export type whatifResponse_TotalExecutiveSummaryResponseSchema_ = {
  readonly baseline: totalExecutiveSummaryResponseSchema; 
  readonly projected: totalExecutiveSummaryResponseSchema; 
  readonly diff: Dict_t<(undefined | number)>; 
  readonly percent_diff: Dict_t<(undefined | number)>; 
  readonly whatif_applied: Dict_t<whatifResponse_TotalExecutiveSummaryResponseSchema__whatif_applied>; 
  readonly model_info: whatifResponse_TotalExecutiveSummaryResponseSchema__model_info; 
  readonly warnings: (undefined | string[])
};
