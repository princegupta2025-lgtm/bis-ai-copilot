#!/usr/bin/env python3
"""
BIS Trust Copilot / MANAK-AI (SIH26107)
Knowledge Store Initialization & Structure Manager
Creates and validates the unified logical structure in data/bis_knowledge/
"""

import os
import sys
import json
import hashlib
import time

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(ROOT_DIR, "data")
BIS_KNOWLEDGE_DIR = os.path.join(DATA_DIR, "bis_knowledge")
BIS_CATALOGUE_DIR = os.path.join(DATA_DIR, "bis_catalogue")

SUBDIRECTORIES = [
    "catalogue",
    "documents",
    "clauses",
    "subclauses",
    "tables",
    "tests",
    "sti",
    "qco",
    "schemes",
    "laboratories",
    "products",
    "regulations",
    "amendments",
    "versions",
    "graph",
    "embeddings",
    "provenance",
    "web_evidence",
    "indexes",
    "manifests"
]

def init_knowledge_store():
    print(f"Initializing Unified BIS Knowledge Store in: {BIS_KNOWLEDGE_DIR}")
    for subdir in SUBDIRECTORIES:
        p = os.path.join(BIS_KNOWLEDGE_DIR, subdir)
        os.makedirs(p, exist_ok=True)
    
    # 1. Create Knowledge Store Schema Descriptor
    schema_desc = {
        "name": "BIS Unified Knowledge Store",
        "version": "3.0.0",
        "problemStatement": "SIH26107",
        "organization": "Bureau of Indian Standards / Department of Consumer Affairs (DoCA)",
        "createdAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "evidenceLevels": {
            "1": "Authorized Full-Text Gazette Standards (Official BIS Publications)",
            "2": "Verified Clauses, Tables, Tolerances & STI Procedures",
            "3": "National Standards Catalogue Metadata (23,401 Standards)",
            "4": "Official Statutory QCOs, Gazette Notifications & Live Web Evidence"
        },
        "subdirectories": {d: f"Authoritative store for {d}" for d in SUBDIRECTORIES}
    }
    
    with open(os.path.join(BIS_KNOWLEDGE_DIR, "manifests", "schema.json"), "w", encoding="utf-8") as f:
        json.dump(schema_desc, f, indent=2)
    
    # 2. Populate schemes from statutory baseline
    schemes_data = {
        "schemes": [
            {
                "id": "scheme_1",
                "name": "Scheme-I (Product Certification / ISI Mark)",
                "type": "Product Certification",
                "authority": "BIS Act 2016 Section 13 / Conformity Assessment Regulations 2018",
                "coverage": "Domestic manufacturers and Foreign Manufacturers Certification Scheme (FMCS)",
                "identifierFormat": "CM/L-XXXXXXX (7 or 8 digits)",
                "processSteps": [
                    "Standard Identification & Gap Analysis on Manakonline",
                    "In-House Laboratory Setup & STI Implementation",
                    "Application Submission (Form I) with Factory Layout and Quality Manual",
                    "Factory Audit & Sample Drawing by BIS Quality Assurance Officers",
                    "Independent Sample Testing at BIS / NABL Recognized Labs",
                    "Grant of CM/L Licence",
                    "Periodic Surveillance Audits & Market Sample Testing"
                ],
                "msmeBenefits": "50% concession on marking fees for Micro & Small Enterprises with Udyam registration."
            },
            {
                "id": "scheme_2",
                "name": "Scheme-II (Compulsory Registration Scheme - CRS)",
                "type": "Self-Declaration of Conformity",
                "authority": "MeitY / MNRE / BIS Act 2016",
                "coverage": "Information Technology, Electronic Products, Solar Inverters, LED Lighting",
                "identifierFormat": "R-XXXXXXXX (8 digits)",
                "processSteps": [
                    "Product Testing in BIS-Recognized Lab under LRS",
                    "Self-Declaration of Conformity based on Test Report",
                    "Online Registration on CRS Portal (crsbis.in)",
                    "Grant of Registration Number (R-Number)",
                    "Labeling with Standard Mark (IS XXXXX / R-XXXXXXXX)"
                ]
            },
            {
                "id": "scheme_3",
                "name": "Scheme-III (Eco Mark Scheme)",
                "type": "Environmental & Quality Certification",
                "authority": "Ministry of Environment, Forest & Climate Change / BIS",
                "coverage": "Products meeting environmental criteria alongside Indian Standards quality benchmarks."
            },
            {
                "id": "scheme_4",
                "name": "Scheme-IV (Hallmarking of Precious Metals)",
                "type": "Hallmarking & Purity Certification",
                "authority": "BIS (Hallmarking) Regulations, 2018 / MoCA QCO",
                "coverage": "Gold & Silver Jewellery and Artefacts",
                "marks": [
                    "BIS Triangular Logo",
                    "Purity Grade (e.g., 22K916, 18K750, 14K585)",
                    "6-Digit Alphanumeric Laser HUID (e.g., AB8492)"
                ],
                "testingMethods": ["XRF Spectrometry (IS 1417)", "Fire Assay Cupellation (IS 1418)"],
                "compensationFormula": "3 * (Billed Purity % - Assayed Purity %) * Weight (grams) * Rate per gram"
            },
            {
                "id": "scheme_x",
                "name": "Scheme-X / MSCS (Management Systems Certification Scheme)",
                "type": "Management Systems Certification",
                "standards": [
                    "IS/ISO 9001 (Quality Management Systems - QMS)",
                    "IS/ISO 14001 (Environmental Management Systems - EMS)",
                    "IS/ISO 22000 (Food Safety Management Systems - FSMS)",
                    "IS/ISO 27001 (Information Security Management Systems - ISMS)",
                    "IS/ISO 45001 (Occupational Health & Safety - OH&SMS)"
                ]
            }
        ]
    }
    with open(os.path.join(BIS_KNOWLEDGE_DIR, "schemes", "conformity_schemes.json"), "w", encoding="utf-8") as f:
        json.dump(schemes_data, f, indent=2)
    
    # 3. Populate laboratories registry
    labs_data = {
        "centralLab": {
            "name": "BIS Central Laboratory",
            "location": "Plot No. 20/9, Site IV, Sahibabad Industrial Area, Ghaziabad, UP - 201010",
            "scope": "Comprehensive Chemical, Electrical, Mechanical, Microbiological, Civil and Food Testing"
        },
        "regionalLabs": [
            {
                "region": "Western Regional Laboratory (WROL)",
                "location": "Manakalaya, E-9, MIDC, Andheri (East), Mumbai - 400093",
                "specialties": ["Chemical", "Mechanical", "Metallurgical", "Electrical"]
            },
            {
                "region": "Eastern Regional Laboratory (EROL)",
                "location": "1/14, C.I.T. Scheme VII M, V.I.P. Road, Kolkata - 700054",
                "specialties": ["Food & Water", "Microbiology", "Electrical", "Chemical"]
            },
            {
                "region": "Southern Regional Laboratory (SROL)",
                "location": "CIT Campus, IV Cross Road, Taramani, Chennai - 600113",
                "specialties": ["Electronics", "Batteries", "Solar PV", "Chemical"]
            },
            {
                "region": "Northern Regional Laboratory (NROL)",
                "location": "Plot No. 4-A, Sector 27-B, Mohali, Punjab - 160019",
                "specialties": ["Mechanical", "Steel & Rebars", "Cables", "Helmets"]
            }
        ],
        "labRecognitionScheme": {
            "name": "Laboratory Recognition Scheme (LRS)",
            "standard": "ISO/IEC 17025 (NABL Accreditation)",
            "description": "BIS recognizes external third-party and government testing laboratories for testing samples of products under domestic and foreign certification schemes."
        },
        "assayingCentres": {
            "name": "BIS-Recognized Assaying and Hallmarking Centres (AHCs)",
            "auditStandard": "IS 15820",
            "description": "Certified testing facilities equipped with XRF and Lead Fire Assay Cupellation for hallmarking jewellery with laser HUID."
        }
    }
    with open(os.path.join(BIS_KNOWLEDGE_DIR, "laboratories", "testing_laboratories.json"), "w", encoding="utf-8") as f:
        json.dump(labs_data, f, indent=2)

    print("Knowledge store directories & foundational schemas created successfully.")

if __name__ == "__main__":
    init_knowledge_store()
