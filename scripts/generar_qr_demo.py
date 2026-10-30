"""Generar un recibo QR sintético: pip install 'qrcode[pil]'. No valida hardware."""
import argparse
import json
from pathlib import Path

import qrcode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('artifacts/qr-demo.png'))
    parser.add_argument('--deposit-id', default='demo-scanner-test-001')
    parser.add_argument(
        '--point-id', default='00000000-0000-4000-8000-000000000001',
        help='UUID del tacho (por defecto Arquitectura; usa el de un tacho creado por el admin)',
    )
    parser.add_argument('--material', choices=['pet', 'aluminum'], default='pet')
    parser.add_argument('--quantity', type=int, default=2, choices=range(1, 101), metavar='1..100')
    args = parser.parse_args()
    payload = {
        'type': 'qupawasi.deposit', 'version': 1, 'depositId': args.deposit_id,
        'pointId': args.point_id,
        'material': args.material, 'quantity': args.quantity,
        'occurredAt': '2026-10-28T10:00:00-05:00',
        'latitude': 0.0, 'longitude': 0.0,
    }
    raw = json.dumps(payload, ensure_ascii=False, separators=(',', ':'))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=10, border=4)
    qr.add_data(raw)
    qr.make(fit=True)
    qr.make_image(fill_color='black', back_color='white').save(args.output)
    args.output.with_suffix('.json').write_text(raw + '\n', encoding='utf-8')
    print(f'QR sintético (0,0), {args.material} x{args.quantity}, tacho {args.point_id}: {args.output.resolve()}')


if __name__ == '__main__':
    main()
