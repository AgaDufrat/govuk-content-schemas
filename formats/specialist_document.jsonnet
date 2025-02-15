(import "shared/default_format.jsonnet") + {
  document_type: [
    "aaib_report",
    "asylum_support_decision",
    "business_finance_support_scheme",
    "cma_case",
    "uk_market_conformity_assessment_body",
    "countryside_stewardship_grant",
    "dfid_research_output",
    "drug_safety_update",
    "employment_appeal_tribunal_decision",
    "employment_tribunal_decision",
    "esi_fund",
    "export_health_certificate",
    "international_development_fund",
    "maib_report",
    "medical_safety_alert",
    "raib_report",
    "residential_property_tribunal_decision",
    "service_standard_report",
    "statutory_instrument",
    "tax_tribunal_decision",
    "utaac_decision",
  ],
  definitions: (import "shared/definitions/_specialist_document.jsonnet") + {
    details: {
      type: "object",
      additionalProperties: false,
      required: [
        "body",
        "metadata",
      ],
      properties: {
        body: {
          "$ref": "#/definitions/body_html_and_govspeak",
        },
        attachments: {
          "$ref": "#/definitions/asset_link_list",
        },
        metadata: {
          "$ref": "#/definitions/any_metadata",
        },
        max_cache_time: {
          "$ref": "#/definitions/max_cache_time",
        },
        headers: {
          "$ref": "#/definitions/nested_headers",
        },
        change_history: {
          "$ref": "#/definitions/change_history",
        },
        temporary_update_type: {
          type: "boolean",
          description: "Indicates that the user should choose a new update type on the next save.",
        },
      },
    },
  },
  edition_links: {
    finder: {
      required: true,
      description: "The finder for this specialist document.",
      minItems: 1,
      maxItems: 1,
    },
    primary_publishing_organisation: {
      description: "The primary organisation for this document",
    },
    organisations: {
      description: "Associated organisations for this document",
    },
  },
}
