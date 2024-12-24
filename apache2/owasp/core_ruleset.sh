#!/bin/bash

function fn_core_ruleset () {

    local vr_file_req="/usr/share/modsecurity-crs/coreruleset-4.0.0/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example"
    local vr_file_res="/usr/share/modsecurity-crs/coreruleset-4.0.0/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example"

    if [ -f "$vr_file_req" ]; then

        cp -rf /usr/share/modsecurity-crs/coreruleset-4.0.0/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.{conf.example,conf}

    fi

    if [ -f "" ]; then

        cp -rf /usr/share/modsecurity-crs/coreruleset-4.0.0/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.{conf.example,conf}
    
    fi

    local vr_owasp_crs="/usr/share/modsecurity-crs/owasp-crs.load"
    local vr_owasp_load=(
        "Include /usr/share/modsecurity-crs/coreruleset-4.0.0/crs-setup.conf"
        "IncludeOptional /usr/share/modsecurity-crs/coreruleset-4.0.0/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf"
        "Include /usr/share/modsecurity-crs/coreruleset-4.0.0/rules/*.conf"
        "IncludeOptional /usr/share/modsecurity-crs/coreruleset-4.0.0/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf"
    )

    local vr_control

    # Creamos archivo temporal
    local tmp_owasp=$(mktemp) || { echo "Error al copiar $vr_owasp_crs"; exit 1; }

    while IFS= read -r line_owasp || [ -n "$line_owasp" ]; do

        vr_control=false

        if [[ "$line_owasp" == "Include"* ]]; then

            vr_control=true
        
        fi

        if [[ "$vr_control" == "false" ]]; then

            echo "$line_owasp" >> "$tmp_owasp"
        
        fi

    done < "$vr_owasp_crs"

    for owasp in "${vr_owasp_load[@]}"; do

        echo "$owasp" >> "$tmp_owasp"

    done

    # Reemplazar el archivo de origen con el temporal
    mv "$tmp_owasp" "$vr_owasp_crs" || { echo "Error al mover archivo temporal"; exit 1; }

    # Limpieza: eliminar el archivo temporal
    rm -f "$tmp_owasp"

    systemctl reload apache2

}

fn_core_ruleset

exit

/usr/share/modsecurity-crs/coreruleset-4.0.0/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
# Descomentar y ajustar el nivel de paranoia (1-4)
SecAction \
    "id:900000,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.paranoia_level=2"

Los niveles de paranoia van del 1 al 4:

    Nivel 1: Protección básica
    Nivel 2: Protección moderada (recomendado)
    Nivel 3: Protección alta
    Nivel 4: Protección muy alta

    Enforcement Mode

# Activar modo de enforcement
SecAction \
    "id:900001,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.enforce_bodyproc_urlencoded=1"


Blocking Score Threshold

# Configurar umbral de bloqueo
SecAction \
    "id:900100,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.blocking_anomaly_score=5"

Inbound and Outbound Anomaly Score Thresholds

# Umbrales de puntuación de anomalías
SecAction \
    "id:900110,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.inbound_anomaly_score_threshold=5,\
    setvar:tx.outbound_anomaly_score_threshold=4"

Critical Anomaly Score

# Puntuación para anomalías críticas
SecAction \
    "id:900120,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.critical_anomaly_score=5,\
    setvar:tx.error_anomaly_score=4,\
    setvar:tx.warning_anomaly_score=3,\
    setvar:tx.notice_anomaly_score=2"

HTTP Policy Settings

# Configuración de política HTTP
SecAction \
    "id:900200,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:'tx.allowed_methods=GET HEAD POST OPTIONS',\
    setvar:'tx.allowed_request_content_type=application/x-www-form-urlencoded|multipart/form-data|text/xml|application/xml|application/json',\
    setvar:'tx.allowed_http_versions=HTTP/1.0 HTTP/1.1 HTTP/2 HTTP/2.0',\
    setvar:'tx.restricted_extensions=.asa/ .asax/ .ascx/ .axd/ .backup/ .bak/ .bat/ .cdx/ .cer/ .cfg/ .cmd/ .com/ .config/ .conf/ .cs/ .csproj/ .csr/ .dat/ .db/ .dbf/ .dll/ .dos/ .htr/ .htw/ .ida/ .idc/ .idq/ .inc/ .ini/ .key/ .licx/ .lnk/ .log/ .mdb/ .old/ .pass/ .pdb/ .pol/ .printer/ .pwd/ .resources/ .resx/ .sql/ .sys/ .vb/ .vbs/ .vbproj/ .vsdisco/ .webinfo/ .xsd/ .xsx/',\
    setvar:'tx.restricted_headers=/proxy/ /lock-token/ /content-range/ /translate/ /if/'"

Scanner Detection

# Detección de escáneres
SecAction \
    "id:900600,\
    phase:1,\
    nolog,\
    pass,\
    t:none,\
    setvar:tx.detect_scanner_threshold=5"


