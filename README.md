# SwiftBox Help Center

A production-ready documentation site for SwiftBox, a fictional parcel delivery service. The site demonstrates Docs-as-Code practices with MkDocs, Material for MkDocs, clear information architecture, and practical developer documentation.

## Project Overview

This project demonstrates professional technical writing and documentation architecture suitable for a real-world customer and partner help center. The site includes:

- **Getting Started** - Account setup and first order guide
- **Order Tracking** - Shipment status lifecycle and webhook integration
- **Pricing & Billing** - Plan comparison, payment methods, taxes, and invoices
- **Partner API** - REST API reference with request and response examples

## Live Demo

View the hosted demo [here](https://ikiiihiyori.github.io/swiftbox-api-docs/).


## Tech Stack

- **MkDocs** - Static site generator for documentation
- **Material for MkDocs** - Responsive, accessible documentation theme
- **Netlify** - Hosting and deployment platform
- **Markdown** - Source format for all documentation pages

## Screenshots

Screenshots can be added after the site is built and deployed:

- Home page: `screenshots/home.png`
- Partner API reference: `screenshots/api-reference.png`
- Mobile navigation: `screenshots/mobile-navigation.png`

## File Structure

```text
portfolio/
|-- mkdocs.yml              # MkDocs configuration
|-- Makefile                # Build and deployment targets
|-- README.md               # Project overview
`-- docs/
    |-- index.md            # Home page with navigation
    |-- getting-started.md  # Quick start guide
    |-- tracking.md         # Order tracking documentation
    |-- billing.md          # Pricing and billing information
    `-- api.md              # Partner API reference
```

## Local Development

### Prerequisites

Install MkDocs, Material for MkDocs, and the minify plugin used by this project:

```bash
pip install mkdocs mkdocs-material mkdocs-minify-plugin
```

For Netlify deployment, install the Netlify CLI:

```bash
npm install -g netlify-cli
```

### Preview the Site

Start the local development server:

```bash
make serve
```

The site will be available at `http://127.0.0.1:8000`. Changes to Markdown files trigger automatic rebuilds.

## Building and Deployment

### Build the Site

Generate the static site in the `site/` directory:

```bash
make build
```

### Deploy to Netlify

Deploy the production site to Netlify:

```bash
make deploy
```

This requires authentication with Netlify. Run `netlify login` first if you are not already authenticated.

## Contributing

This repository is designed as a portfolio project, but contributions are welcome for clarity, consistency, and technical accuracy. To contribute:

1. Create a feature branch.
2. Make focused documentation changes.
3. Run `mkdocs build --strict`.
4. Open a pull request with a short summary of the change.

## Documentation

- [MkDocs Documentation](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- [Netlify CLI Documentation](https://docs.netlify.com/cli/get-started/)

## License

This portfolio project is available under the MIT License.
