# OpenJEV Support

This fork of [jev-superpowers](https://github.com/AkashPriyadarshii/jev-superpowers) adds optional [OpenJEV](https://openjev.sh) support alongside the original TypeSafe backend. TypeSafe remains the default; OpenJEV is a free community gateway to the same Jev model.

## What was added

| File | Change |
|---|---|
| `install.sh` | Added `OPENJEV_API_KEY` / `JEV_PROVIDER=openjev` provider selection logic alongside existing TypeSafe check |
| `install.ps1` | Same provider selection logic in PowerShell |
| `README.md` | OpenJEV note after intro, new "Option C: OpenJEV Gateway" in Quickstart |
| `skills/jev-using-superpowers/SKILL.md` | Prerequisites now list `OPENJEV_API_KEY` as an alternative to `TYPESAFE_API_KEY` |
| `site/system-one.html` | OpenJEV endpoint noted alongside TypeSafe API example |

## Provider selection rule

1. `JEV_PROVIDER=openjev` → OpenJEV (explicit choice wins)
2. `TYPESAFE_API_KEY` is set → TypeSafe (unchanged default)
3. Only `OPENJEV_API_KEY` is set → OpenJEV
4. `TYPESAFE_BASE_URL` set or `TYPESAFE_BACKEND=laya` → Local FOSS Laya (unchanged)

Anyone with a TypeSafe key sees zero behaviour change.

## Configuration

```bash
# OpenJEV (free community gateway)
export OPENJEV_API_KEY="your_key_from_openjev_sh_dashboard"

# Or force OpenJEV even when TYPESAFE_API_KEY is also set
export JEV_PROVIDER=openjev
```

- OpenJEV endpoint: `https://api.openjev.sh/v1/systemone`
- OpenJEV model id: `openjev`
- OpenJEV key env: `OPENJEV_API_KEY`
- Retryable HTTP statuses: 429, 503 (OpenJEV), 529 (TypeSafe)

## Verification

A live POST to `https://api.openjev.sh/v1/systemone` with model `openjev`, state `ping`, and one noul question returned HTTP 200. No repo code was executed during the port.

## Upstream

Original project: https://github.com/AkashPriyadarshii/jev-superpowers by @AkashPriyadarshii
