#!/usr/bin/env python3
"""
BIS Trust Copilot / MANAK-AI (SIH26107)
Comprehensive Relational Knowledge Graph Builder

Builds the multi-dimensional knowledge graph in data/bis_catalogue/knowledge_graph.json
representing the entire ecosystem of Standards, Editions, Clauses, QCOs, Gazette Orders,
Central Ministries, Certification Schemes, Technical Divisions, Laboratories, and Licenses.
"""

import sys
import os
import json
from collections import defaultdict

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(ROOT_DIR, "data")
CATALOGUE_DIR = os.path.join(DATA_DIR, "bis_catalogue")
KG_FILE = os.path.join(CATALOGUE_DIR, "knowledge_graph.json")
COV_REG_FILE = os.path.join(DATA_DIR, "bis_knowledge", "coverage_registry.json")
RAG_FILE = os.path.join(DATA_DIR, "bis_rag_embeddings.json")

def build_graph():
    print("=" * 75)
    print("BUILDING COMPREHENSIVE BIS RELATIONAL KNOWLEDGE GRAPH")
    print("=" * 75)

    nodes = {}
    edges = []

    # 1. Technical Divisions (15 Nodes)
    divisions = {
        "CED": "Civil Engineering Division",
        "CHD": "Chemical Division",
        "ETD": "Electrotechnical Division",
        "TED": "Transport Engineering Division",
        "MTD": "Metallurgical Engineering Division",
        "FAD": "Food and Agriculture Division",
        "TXD": "Textiles Division",
        "LITD": "Electronics and Information Technology Division",
        "PCD": "Petroleum, Coal and Related Products Division",
        "PGD": "Production and General Engineering Division",
        "MHD": "Medical Equipment and Hospital Planning Division",
        "WRD": "Water Resources Division",
        "MSD": "Management and Systems Division",
        "EVD": "Environment and Ecology Division",
        "SSD": "Services Sector Division"
    }
    for code, name in divisions.items():
        nid = f"div:{code}"
        nodes[nid] = {"id": nid, "type": "TechnicalDivision", "code": code, "name": name}

    # 2. Certification Schemes (4 Nodes)
    schemes = {
        "Scheme-I": {"name": "Scheme-I (ISI Mark Product Certification)", "type": "Product Certification", "mark": "ISI Standard Mark"},
        "Scheme-II": {"name": "Scheme-II (Compulsory Registration Scheme - CRS)", "type": "Self-Declaration of Conformity", "mark": "CRS Registration Mark"},
        "Scheme-IV": {"name": "Scheme-IV (HUID Hallmarking of Gold and Silver)", "type": "Precious Metals Hallmarking", "mark": "BIS Hallmark + 6-Digit HUID"},
        "Scheme-X": {"name": "Scheme-X (Eco Mark Scheme)", "type": "Environmental Labeling", "mark": "Eco-Mark Earthen Pot Symbol"}
    }
    for sid, sdata in schemes.items():
        nid = f"scheme:{sid}"
        nodes[nid] = {"id": nid, "type": "CertificationScheme", "schemeId": sid, **sdata}

    # 3. Issuing Central Ministries & Statutory Authorities (10 Nodes)
    ministries = {
        "MoCI": "Ministry of Commerce and Industry (DPIIT)",
        "MoRTH": "Ministry of Road Transport and Highways",
        "MoSteel": "Ministry of Steel",
        "MeitY": "Ministry of Electronics and Information Technology",
        "MoPNG": "Ministry of Petroleum and Natural Gas",
        "MoCA": "Ministry of Consumer Affairs, Food and Public Distribution",
        "MoHFW": "Ministry of Health and Family Welfare",
        "MoP": "Ministry of Power",
        "FSSAI": "Food Safety and Standards Authority of India",
        "PESO": "Petroleum and Explosives Safety Organization"
    }
    for mid, mname in ministries.items():
        nid = f"ministry:{mid}"
        nodes[nid] = {"id": nid, "type": "StatutoryAuthority", "code": mid, "name": mname}

    # 4. Laboratories & Assaying Infrastructure (4 Nodes)
    labs = {
        "BIS-CL-Sahibabad": {"name": "BIS Central Laboratory (Sahibabad)", "city": "Ghaziabad", "scope": "Multi-Discipline National Reference Laboratory"},
        "NABL-Accredited-Network": {"name": "NABL Accredited Third-Party Testing Network", "scope": "Conformity Assessment Testing across India"},
        "Assaying-Hallmarking-Centres": {"name": "BIS Recognized Assaying and Hallmarking Centres (AHCs)", "scope": "XRF Spectrometry & Lead Fire Assay for HUID"}
    }
    for lid, ldata in labs.items():
        nid = f"lab:{lid}"
        nodes[nid] = {"id": nid, "type": "TestingLaboratory", "code": lid, **ldata}

    # 5. Load Standards from Coverage Registry & Verified RAG Chunks
    if os.path.exists(COV_REG_FILE):
        with open(COV_REG_FILE, "r", encoding="utf-8-sig") as f:
            cov_data = json.load(f)
            reg_dict = cov_data.get("registry", {})
            for code, s in reg_dict.items():
                if s.get("full_text_ingested") or s.get("mandatory") or s.get("current_status") == "SUPERSEDED":
                    std_id = f"std:{code}"
                    nodes[std_id] = {
                        "id": std_id,
                        "type": "IndianStandard",
                        "code": code,
                        "title": s.get("title"),
                        "year": s.get("year"),
                        "division": s.get("division"),
                        "status": s.get("current_status"),
                        "isMandatory": s.get("mandatory"),
                        "evidenceLevel": s.get("evidence_level")
                    }

                    # Link to Division
                    div_id = f"div:{s.get('division')}"
                    if div_id in nodes:
                        edges.append({"source": std_id, "target": div_id, "relation": "BELONGS_TO_DIVISION"})

                    # Link to Scheme
                    for sch_name in s.get("scheme_links", []):
                        for sch_key in schemes:
                            if sch_key in sch_name:
                                edges.append({"source": std_id, "target": f"scheme:{sch_key}", "relation": "GOVERNED_BY_SCHEME"})

                    # Link to QCO
                    for qco_text in s.get("qco_links", []):
                        qco_id = f"qco:{code}"
                        nodes[qco_id] = {"id": qco_id, "type": "QualityControlOrder", "name": qco_text, "standard": code}
                        edges.append({"source": std_id, "target": qco_id, "relation": "MANDATED_BY_QCO"})

                    # Link to Supersession
                    sup_by = s.get("superseded_by")
                    if sup_by:
                        sup_id = f"std:{sup_by}"
                        if sup_id not in nodes:
                            nodes[sup_id] = {"id": sup_id, "type": "IndianStandard", "code": sup_by, "status": "CURRENT"}
                        edges.append({"source": std_id, "target": sup_id, "relation": "SUPERSEDED_BY"})

                    # Link to Testing Lab
                    if s.get("division") in ["ETD", "CED", "MED", "CHD"]:
                        edges.append({"source": std_id, "target": "lab:BIS-CL-Sahibabad", "relation": "TESTED_BY_LAB"})
                    elif s.get("division") == "MTD" and "1417" in code:
                        edges.append({"source": std_id, "target": "lab:Assaying-Hallmarking-Centres", "relation": "TESTED_BY_LAB"})

    # Deduplicate Edges
    seen_edges = set()
    dedup_edges = []
    for e in edges:
        ekey = f"{e.get('source')}->{e.get('relation')}->{e.get('target')}"
        if ekey not in seen_edges:
            seen_edges.add(ekey)
            dedup_edges.append(e)

    kg_out = {
        "graphGeneratedAt": json.loads(open(COV_REG_FILE, "r", encoding="utf-8-sig").read()).get("registryGeneratedAt") if os.path.exists(COV_REG_FILE) else "2026-08-30T00:00:00Z",
        "project": "BIS Trust Copilot / MANAK-AI (SIH26107)",
        "totalNodes": len(nodes),
        "totalEdges": len(dedup_edges),
        "nodes": nodes,
        "edges": dedup_edges
    }

    with open(KG_FILE, "w", encoding="utf-8") as f:
        json.dump(kg_out, f, indent=2)

    print(f"[OK] Successfully built knowledge graph in {KG_FILE}")
    print(f"  Total Entities (Nodes) : {len(nodes):,}")
    print(f"  Total Relations (Edges): {len(dedup_edges):,}")
    print("=" * 75)

if __name__ == "__main__":
    build_graph()
