from __future__ import annotations

import uuid
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import Dict, List

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Mock Site & Aidat API")


@dataclass
class Unit:
    id: str
    block: str
    floor: int
    number: str
    square_meter: float
    land_share: float
    tenant_id: str


@dataclass
class Period:
    id: str
    name: str
    site_id: str
    status: str
    expenses: List[Dict]
    generated_invoices: List[str]
    created_at: datetime


@dataclass
class Invoice:
    id: str
    period_id: str
    period_name: str
    unit_id: str
    tenant_id: str
    tenant_name: str
    items: List[Dict]
    total: float
    payment_status: str


class PaymentIntent(BaseModel):
    invoice_id: str
    gateway: str
    checkout_form_token: str
    redirect_url: str


def _mock_units() -> List[Unit]:
    return [
        Unit(
            id="unit-1",
            block="A",
            floor=1,
            number="1",
            square_meter=110,
            land_share=10,
            tenant_id="tenant-1",
        ),
        Unit(
            id="unit-2",
            block="A",
            floor=2,
            number="2",
            square_meter=95,
            land_share=8,
            tenant_id="tenant-2",
        ),
    ]


SITE = {
    "id": "demo-site",
    "name": "Demo Sitesi",
    "roles": ["superadmin", "site_yoneticisi", "muhasebe", "personel", "sakin"],
    "units": [asdict(unit) for unit in _mock_units()],
}

PERIODS: Dict[str, Period] = {}
INVOICES: Dict[str, Invoice] = {}


@app.get("/sites/{site_id}")
def get_site(site_id: str):
    if site_id != SITE["id"]:
        raise HTTPException(status_code=404, detail="Site bulunamadı")
    return SITE


@app.get("/sites/{site_id}/periods")
def list_periods(site_id: str):
    return [asdict(period) for period in PERIODS.values() if period.site_id == site_id]


@app.post("/sites/{site_id}/periods")
def upsert_period(site_id: str, payload: Dict):
    period_id = payload.get("id") or str(uuid.uuid4())
    period = Period(
        id=period_id,
        name=payload["name"],
        site_id=site_id,
        status=payload.get("status", "draft"),
        expenses=payload.get("expenses", []),
        generated_invoices=payload.get("generated_invoices", []),
        created_at=datetime.utcnow(),
    )
    PERIODS[period_id] = period
    return asdict(period)


@app.post("/sites/{site_id}/periods/{period_id}/run")
def run_period(site_id: str, period_id: str, payload: Dict):
    period = PERIODS.get(period_id)
    if not period:
        period = Period(
            id=period_id,
            name=payload.get("name", "Yeni Dönem"),
            site_id=site_id,
            status="processing",
            expenses=payload.get("expenses", []),
            generated_invoices=[],
            created_at=datetime.utcnow(),
        )
        PERIODS[period_id] = period

    invoices: List[Dict] = []
    total_land_share = sum(unit["land_share"] for unit in SITE["units"])
    total_square = sum(unit["square_meter"] for unit in SITE["units"])

    for unit in SITE["units"]:
        items = []
        total_amount = 0.0
        for expense in payload.get("expenses", []):
            dist_type = expense["distribution_type"]
            amount = float(expense["amount"])
            if dist_type == "landShare":
                share = unit["land_share"] / total_land_share
                allocated = amount * share
            elif dist_type == "squareMeter":
                share = unit["square_meter"] / total_square
                allocated = amount * share
            elif dist_type == "fixed":
                allocated = amount / len(SITE["units"])
            else:
                readings = expense.get("meter_readings", {})
                unit_reading = float(readings.get(unit["id"], 0))
                total_readings = sum(float(value) for value in readings.values()) or 1
                allocated = amount * unit_reading / total_readings
            items.append({
                "description": expense["name"],
                "amount": round(allocated, 2),
            })
            total_amount += allocated
        invoice_id = str(uuid.uuid4())
        invoice = Invoice(
            id=invoice_id,
            period_id=period.id,
            period_name=period.name,
            unit_id=unit["id"],
            tenant_id=unit["tenant_id"],
            tenant_name=f"Sakin {unit['number']}",
            items=items,
            total=round(total_amount, 2),
            payment_status="unpaid",
        )
        INVOICES[invoice_id] = invoice
        invoices.append(asdict(invoice))

    period.generated_invoices = [invoice["id"] for invoice in invoices]
    period.status = "processing"
    return invoices


@app.post("/sites/{site_id}/periods/{period_id}/publish")
def publish_period(site_id: str, period_id: str):
    period = PERIODS.get(period_id)
    if not period:
        raise HTTPException(status_code=404, detail="Dönem bulunamadı")
    period.status = "published"
    return asdict(period)


@app.post("/sites/{site_id}/invoices/{invoice_id}/payments")
def create_payment(site_id: str, invoice_id: str, payload: Dict):
    invoice = INVOICES.get(invoice_id)
    if not invoice:
        raise HTTPException(status_code=404, detail="Fatura bulunamadı")
    gateway = payload.get("gateway", "iyzico")
    return PaymentIntent(
        invoice_id=invoice.id,
        gateway=gateway,
        checkout_form_token=str(uuid.uuid4()),
        redirect_url=f"https://{gateway}.example.com/pay/{invoice.id}",
    )


@app.put("/sites/{site_id}/invoices/{invoice_id}")
def mark_invoice_paid(site_id: str, invoice_id: str, payload: Dict):
    invoice = INVOICES.get(invoice_id)
    if not invoice:
        raise HTTPException(status_code=404, detail="Fatura bulunamadı")
    invoice.payment_status = payload.get("status", "paid")
    INVOICES[invoice_id] = invoice
    return {"status": invoice.payment_status}
