const fs = require("fs");
const path = require("path");
const {
  AlignmentType,
  BorderStyle,
  Document,
  Footer,
  HeadingLevel,
  PageNumber,
  PageOrientation,
  Packer,
  Paragraph,
  Table,
  TableCell,
  TableRow,
  TextRun,
  WidthType,
} = require("docx");

const rootDir = path.resolve(__dirname, "..");
const sourcePath = path.join(
  rootDir,
  "ВСТАВКА_ГЛАВА_1_СРАВНЕНИЕ_РЕАЛЬНЫХ_АНАЛОГОВ.md",
);
const outPath = path.join(
  __dirname,
  "docx",
  "ВКР_глава_1_вставка_сравнение_аналогов.docx",
);

const A4_WIDTH = 11906;
const A4_HEIGHT = 16838;
const PAGE_MARGINS = {
  top: 1134,
  right: 850,
  bottom: 1134,
  left: 850,
};
const LANDSCAPE_CONTENT_WIDTH = A4_HEIGHT - PAGE_MARGINS.left - PAGE_MARGINS.right;

const border = { style: BorderStyle.SINGLE, size: 1, color: "000000" };
const borders = {
  top: border,
  bottom: border,
  left: border,
  right: border,
};

function cleanInline(text) {
  return text
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, "$1")
    .replace(/`([^`]+)`/g, "$1")
    .trim();
}

function parseInline(text, options = {}) {
  const normalized = cleanInline(text);
  const runs = [];
  const pattern = /(\*\*[^*]+\*\*|\*[^*]+\*)/g;
  let lastIndex = 0;

  for (const match of normalized.matchAll(pattern)) {
    const index = match.index ?? 0;
    if (index > lastIndex) {
      runs.push(
        new TextRun({
          text: normalized.slice(lastIndex, index),
          font: "Times New Roman",
          size: options.size ?? 28,
        }),
      );
    }

    const token = match[0];
    if (token.startsWith("**")) {
      runs.push(
        new TextRun({
          text: token.slice(2, -2),
          bold: true,
          font: "Times New Roman",
          size: options.size ?? 28,
        }),
      );
    } else {
      runs.push(
        new TextRun({
          text: token.slice(1, -1),
          italics: true,
          font: "Times New Roman",
          size: options.size ?? 28,
        }),
      );
    }
    lastIndex = index + token.length;
  }

  if (lastIndex < normalized.length) {
    runs.push(
      new TextRun({
        text: normalized.slice(lastIndex),
        font: "Times New Roman",
        size: options.size ?? 28,
      }),
    );
  }

  return runs.length
    ? runs
    : [
        new TextRun({
          text: normalized,
          font: "Times New Roman",
          size: options.size ?? 28,
        }),
      ];
}

function makeParagraph(text, options = {}) {
  return new Paragraph({
    children: parseInline(text, { size: options.size }),
    alignment: options.alignment ?? AlignmentType.JUSTIFIED,
    spacing: options.spacing ?? { after: 120, line: 360 },
    indent: options.indent ?? { firstLine: 709 },
    keepLines: true,
  });
}

function makeHeading(text, level) {
  return new Paragraph({
    heading: level,
    spacing: { before: 120, after: 120 },
    children: [
      new TextRun({
        text: cleanInline(text),
        font: "Times New Roman",
      }),
    ],
  });
}

function splitTableRow(line) {
  return line
    .trim()
    .replace(/^\|/, "")
    .replace(/\|$/, "")
    .split("|")
    .map((cell) => cleanInline(cell.trim()));
}

function buildTable(lines) {
  const rows = lines
    .map(splitTableRow)
    .filter((row) => !row.every((cell) => /^:?-{3,}:?$/.test(cell)));

  const tableWidth = LANDSCAPE_CONTENT_WIDTH;
  const widths = [1900, 2200, 2200, 1600, 1600, 2400, tableWidth - 11900];

  return new Table({
    width: { size: tableWidth, type: WidthType.DXA },
    columnWidths: widths,
    rows: rows.map((cells, rowIndex) =>
      new TableRow({
        children: cells.map((cell, cellIndex) =>
          new TableCell({
            borders,
            width: {
              size: widths[cellIndex] ?? Math.floor(tableWidth / cells.length),
              type: WidthType.DXA,
            },
            margins: { top: 100, bottom: 100, left: 100, right: 100 },
            shading:
              rowIndex === 0
                ? { fill: "D9EAF7" }
                : undefined,
            children: [
              new Paragraph({
                children: parseInline(cell),
                alignment:
                  rowIndex === 0 ? AlignmentType.CENTER : AlignmentType.LEFT,
                spacing: { after: 60, line: 300 },
                indent: { firstLine: 0 },
              }),
            ],
          }),
        ),
      }),
    ),
  });
}

function parseMarkdown(md) {
  const lines = md.replace(/\r\n/g, "\n").split("\n");
  const children = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i].trimEnd();
    const trimmed = line.trim();

    if (!trimmed) {
      i += 1;
      continue;
    }

    if (trimmed.startsWith("# ")) {
      children.push(makeHeading(trimmed.slice(2), HeadingLevel.HEADING_1));
      i += 1;
      continue;
    }

    if (trimmed.startsWith("## ")) {
      children.push(makeHeading(trimmed.slice(3), HeadingLevel.HEADING_2));
      i += 1;
      continue;
    }

    if (trimmed.startsWith("### ")) {
      children.push(makeHeading(trimmed.slice(4), HeadingLevel.HEADING_3));
      i += 1;
      continue;
    }

    if (trimmed.startsWith("|")) {
      const tableLines = [];
      while (i < lines.length && lines[i].trim().startsWith("|")) {
        tableLines.push(lines[i].trim());
        i += 1;
      }
      children.push(buildTable(tableLines));
      continue;
    }

    if (/^\d+\.\s+/.test(trimmed)) {
      children.push(
        makeParagraph(trimmed, {
          indent: { left: 360, firstLine: 0 },
        }),
      );
      i += 1;
      continue;
    }

    if (/^- /.test(trimmed)) {
      children.push(
        makeParagraph(trimmed, {
          indent: { left: 360, firstLine: 0 },
        }),
      );
      i += 1;
      continue;
    }

    if (/^Таблица /.test(trimmed)) {
      children.push(
        makeParagraph(trimmed, {
          alignment: AlignmentType.CENTER,
          indent: { firstLine: 0 },
          spacing: { before: 120, after: 120, line: 360 },
        }),
      );
      i += 1;
      continue;
    }

    const paragraphParts = [trimmed];
    i += 1;
    while (i < lines.length) {
      const next = lines[i].trim();
      if (
        !next ||
        next.startsWith("#") ||
        next.startsWith("|") ||
        /^\d+\.\s+/.test(next) ||
        /^- /.test(next) ||
        /^Таблица /.test(next)
      ) {
        break;
      }
      paragraphParts.push(next);
      i += 1;
    }
    children.push(makeParagraph(paragraphParts.join(" ")));
  }

  return children;
}

async function main() {
  const md = fs.readFileSync(sourcePath, "utf8");
  const children = parseMarkdown(md);

  const doc = new Document({
    numbering: { config: [] },
    sections: [
      {
        properties: {
          page: {
            size: {
              width: A4_WIDTH,
              height: A4_HEIGHT,
              orientation: PageOrientation.LANDSCAPE,
            },
            margin: PAGE_MARGINS,
          },
        },
        footers: {
          default: new Footer({
            children: [
              new Paragraph({
                alignment: AlignmentType.CENTER,
                children: [
                  new TextRun({ text: "Стр. ", font: "Times New Roman", size: 24 }),
                  new TextRun({ children: [PageNumber.CURRENT], font: "Times New Roman", size: 24 }),
                ],
              }),
            ],
          }),
        },
        children,
      },
    ],
    styles: {
      default: {
        document: {
          run: {
            font: "Times New Roman",
            size: 28,
          },
        },
      },
    },
  });

  const buffer = await Packer.toBuffer(doc);
  fs.writeFileSync(outPath, buffer);
  console.log(`Written: ${outPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
