#!/usr/bin/env bash
set -e

echo "Recolectando información AWS..."

DATE="$(date -u)"
TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
REPORT="reports/aws-report-${TIMESTAMP}.md"

mkdir -p reports

# Header Markdown
cat <<EOF > "$REPORT"
---
title: AWS Account Report
generated_at: $DATE
author: Claude + AWS CLI
---

# 📊 AWS Account Report

_Generado automáticamente el $DATE_

---

## 👤 Identidad AWS
\`\`\`json
EOF

# Identidad
aws sts get-caller-identity >> "$REPORT"

cat <<EOF >> "$REPORT"
\`\`\`

---

## 🌍 Región por defecto
\`\`\`
EOF

REGION=$(aws configure get region || echo "no-configured")
echo "$REGION" >> "$REPORT"

cat <<EOF >> "$REPORT"
\`\`\`

---

## 🖥️ EC2 Instances (región: $REGION)

\`\`\`
EOF

aws ec2 describe-instances \
  --query "Reservations[].Instances[].{Id:InstanceId,State:State.Name,Type:InstanceType}" \
  --output table >> "$REPORT"

cat <<EOF >> "$REPORT"
\`\`\`

---

## ✅ Fin del reporte
EOF

echo "Reporte generado: $REPORT"
