import * as DomainConfig from '../DomainConfig.res.mjs';
import * as DomainGen from '../DomainGen.res.mjs';
import * as DomainBackend from '../DomainBackend.res.mjs';

describe('DomainConfig Parser', () => {
    test('parse valid config with mapper and passthrough fields', () => {
        const input = {
            modules: {
                AdsSummary: {
                    source: "getAdsExecutiveSummaryResponse",
                    output: "AdsSummary.gen.res",
                    fields: {
                        ad_sales: {
                            type: "Metric.t",
                            mapper: "AdsSummaryMappers.adSales"
                        },
                        campaign: {
                            type: "string"
                        }
                    }
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Ok');
        const config = result._0;
        expect(config.modules.length).toBe(1);

        const [moduleName, moduleConfig] = config.modules[0];
        expect(moduleName).toBe('AdsSummary');
        expect(moduleConfig.source).toBe('getAdsExecutiveSummaryResponse');
        expect(moduleConfig.output).toBe('AdsSummary.gen.res');
        expect(moduleConfig.fields.length).toBe(2);

        const [salesName, salesConfig] = moduleConfig.fields.find(([n]) => n === 'ad_sales');
        expect(salesName).toBe('ad_sales');
        expect(salesConfig.type_).toBe('Metric.t');
        expect(salesConfig.mapper).toBe('AdsSummaryMappers.adSales');
        expect(salesConfig.source).toBeUndefined();

        const [campaignName, campaignConfig] = moduleConfig.fields.find(([n]) => n === 'campaign');
        expect(campaignName).toBe('campaign');
        expect(campaignConfig.type_).toBe('string');
        expect(campaignConfig.mapper).toBeUndefined();
    });

    test('parse config with source field rename', () => {
        const input = {
            modules: {
                MyModule: {
                    source: "apiType",
                    fields: {
                        status: {
                            type: "string",
                            source: "campaignStatus"
                        }
                    }
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Ok');
        const [, moduleConfig] = result._0.modules[0];
        expect(moduleConfig.output).toBeUndefined();

        const [, fieldConfig] = moduleConfig.fields[0];
        expect(fieldConfig.source).toBe('campaignStatus');
    });

    test('error: missing modules', () => {
        const input = {};
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Error');
        expect(result._0.length).toBe(1);
        expect(result._0[0].kind.TAG).toBe('MissingRequiredField');
        expect(result._0[0].kind._0).toBe('modules');
    });

    test('error: missing source in module', () => {
        const input = {
            modules: {
                MyModule: {
                    fields: {
                        name: { type: "string" }
                    }
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Error');
        expect(result._0[0].kind.TAG).toBe('MissingRequiredField');
        expect(result._0[0].kind._0).toBe('source');
        expect(result._0[0].location.path).toEqual(['modules', 'MyModule']);
    });

    test('error: missing fields in module', () => {
        const input = {
            modules: {
                MyModule: {
                    source: "apiType"
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Error');
        expect(result._0[0].kind.TAG).toBe('MissingRequiredField');
        expect(result._0[0].kind._0).toBe('fields');
    });

    test('error: missing type in field', () => {
        const input = {
            modules: {
                MyModule: {
                    source: "apiType",
                    fields: {
                        broken: {
                            mapper: "SomeMapper.fn"
                        }
                    }
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Error');
        expect(result._0[0].kind.TAG).toBe('MissingRequiredField');
        expect(result._0[0].kind._0).toBe('type');
        expect(result._0[0].location.path).toEqual(['fields', 'broken']);
    });

    test('error: config is not an object', () => {
        const result = DomainConfig.parse("not an object");

        expect(result.TAG).toBe('Error');
        expect(result._0[0].kind.TAG).toBe('InvalidJson');
    });

    test('parse multiple modules', () => {
        const input = {
            modules: {
                ModuleA: {
                    source: "typeA",
                    fields: {
                        x: { type: "int" }
                    }
                },
                ModuleB: {
                    source: "typeB",
                    fields: {
                        y: { type: "string" }
                    }
                }
            }
        };
        const result = DomainConfig.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0.modules.length).toBe(2);
    });
});

describe('DomainGen', () => {
    test('generate domain IR from config', () => {
        const config = {
            modules: [
                ["AdsSummary", {
                    source: "getAdsExecutiveSummaryResponse",
                    output: "AdsSummary.gen.res",
                    fields: [
                        ["ad_sales", { type_: "Metric.t", mapper: "AdsSummaryMappers.adSales", source: undefined }],
                        ["campaign", { type_: "string", mapper: undefined, source: undefined }],
                        ["status", { type_: "string", mapper: undefined, source: "campaignStatus" }]
                    ]
                }]
            ]
        };

        const modules = DomainGen.generate(config, "Api");

        expect(modules.length).toBe(1);
        const mod = modules[0];
        expect(mod.name).toBe('AdsSummary');
        expect(mod.sourceType).toBe('Api.getAdsExecutiveSummaryResponse');
        expect(mod.output).toBe('AdsSummary.gen.res');
        expect(mod.fields.length).toBe(3);

        // Mapper field
        expect(mod.fields[0].name).toBe('ad_sales');
        expect(mod.fields[0].typeAnnotation).toBe('Metric.t');
        expect(mod.fields[0].mapping.TAG).toBe('Mapper');
        expect(mod.fields[0].mapping._0).toBe('AdsSummaryMappers.adSales');

        // Passthrough field (no source override)
        expect(mod.fields[1].name).toBe('campaign');
        expect(mod.fields[1].mapping.TAG).toBe('Passthrough');
        expect(mod.fields[1].mapping._0).toBe('campaign');

        // Passthrough field (with source override)
        expect(mod.fields[2].name).toBe('status');
        expect(mod.fields[2].mapping.TAG).toBe('Passthrough');
        expect(mod.fields[2].mapping._0).toBe('campaignStatus');
    });

    test('default output filename from module name', () => {
        const config = {
            modules: [
                ["MyModule", {
                    source: "myApiType",
                    output: undefined,
                    fields: [
                        ["x", { type_: "int", mapper: undefined, source: undefined }]
                    ]
                }]
            ]
        };

        const modules = DomainGen.generate(config, "Api");
        expect(modules[0].output).toBe('MyModule.gen.res');
    });
});

describe('DomainBackend', () => {
    test('print type definition', () => {
        const mod = {
            name: "AdsSummary",
            sourceType: "Api.getAdsExecutiveSummaryResponse",
            output: "AdsSummary.gen.res",
            fields: [
                { name: "ad_sales", typeAnnotation: "Metric.t", mapping: { TAG: "Mapper", _0: "AdsSummaryMappers.adSales" } },
                { name: "campaign", typeAnnotation: "string", mapping: { TAG: "Passthrough", _0: "campaign" } },
            ]
        };

        const code = DomainBackend.printModule(mod);

        // Header
        expect(code).toContain('// AdsSummary.gen.res (generated by osury');
        expect(code).toContain('do not edit');

        // Type definition
        expect(code).toContain('type t = {');
        expect(code).toContain('ad_sales: Metric.t,');
        expect(code).toContain('campaign: string,');

        // Make function
        expect(code).toContain('let make = (raw: Api.getAdsExecutiveSummaryResponse): t => {');
        expect(code).toContain('ad_sales: AdsSummaryMappers.adSales(raw),');
        expect(code).toContain('campaign: raw.campaign,');
    });

    test('print passthrough with source rename', () => {
        const mod = {
            name: "Test",
            sourceType: "Api.testType",
            output: "Test.gen.res",
            fields: [
                { name: "status", typeAnnotation: "string", mapping: { TAG: "Passthrough", _0: "campaignStatus" } },
            ]
        };

        const code = DomainBackend.printModule(mod);
        expect(code).toContain('status: raw.campaignStatus,');
    });
});

describe('Domain E2E: config JSON → ReScript code', () => {
    test('full pipeline: parse config → generate IR → print code', () => {
        const configJson = {
            modules: {
                AdsSummary: {
                    source: "getAdsExecutiveSummaryResponse",
                    fields: {
                        ad_sales: {
                            type: "Metric.t",
                            mapper: "AdsSummaryMappers.adSales"
                        },
                        ad_ctr: {
                            type: "Metric.t",
                            mapper: "AdsSummaryMappers.adCtr"
                        },
                        campaign: {
                            type: "string"
                        },
                        status: {
                            type: "string",
                            source: "campaignStatus"
                        }
                    }
                }
            }
        };

        // Step 1: Parse config
        const parseResult = DomainConfig.parse(configJson);
        expect(parseResult.TAG).toBe('Ok');

        // Step 2: Generate IR
        const modules = DomainGen.generate(parseResult._0, "Api");
        expect(modules.length).toBe(1);

        // Step 3: Print code
        const code = DomainBackend.printModule(modules[0]);

        // Verify generated code
        expect(code).toContain('type t = {');
        expect(code).toContain('ad_sales: Metric.t,');
        expect(code).toContain('ad_ctr: Metric.t,');
        expect(code).toContain('campaign: string,');
        expect(code).toContain('status: string,');

        expect(code).toContain('let make = (raw: Api.getAdsExecutiveSummaryResponse): t => {');
        expect(code).toContain('ad_sales: AdsSummaryMappers.adSales(raw),');
        expect(code).toContain('ad_ctr: AdsSummaryMappers.adCtr(raw),');
        expect(code).toContain('campaign: raw.campaign,');
        expect(code).toContain('status: raw.campaignStatus,');
    });

    test('multiple modules pipeline', () => {
        const configJson = {
            modules: {
                ModuleA: {
                    source: "apiTypeA",
                    output: "ModuleA.gen.res",
                    fields: {
                        value: { type: "Metric.t", mapper: "MappersA.value" }
                    }
                },
                ModuleB: {
                    source: "apiTypeB",
                    fields: {
                        name: { type: "string" }
                    }
                }
            }
        };

        const parseResult = DomainConfig.parse(configJson);
        expect(parseResult.TAG).toBe('Ok');

        const modules = DomainGen.generate(parseResult._0, "MyApi");
        expect(modules.length).toBe(2);

        const codeA = DomainBackend.printModule(modules[0]);
        expect(codeA).toContain('MyApi.apiTypeA');
        expect(codeA).toContain('MappersA.value(raw)');

        const codeB = DomainBackend.printModule(modules[1]);
        expect(codeB).toContain('MyApi.apiTypeB');
        expect(codeB).toContain('name: raw.name,');
        // Default output filename
        expect(modules[1].output).toBe('ModuleB.gen.res');
    });
});
