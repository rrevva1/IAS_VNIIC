const fs = require("fs");
const path = require("path");
const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  ImageRun,
  HeadingLevel,
  AlignmentType,
  WidthType,
  BorderStyle,
  ShadingType,
  Footer,
  PageNumber,
  PageBreak,
  LevelFormat,
} = require("docx");

const baseDir = path.resolve(__dirname, "..");
const exportDir = __dirname;
const imagesDir = path.join(exportDir, "named", "png");
const outDir = path.join(exportDir, "docx");

const A4_WIDTH = 11906;
const A4_HEIGHT = 16838;
const MARGINS = {
  top: 1134,
  right: 850,
  bottom: 1134,
  left: 1701,
};
const CONTENT_WIDTH = A4_WIDTH - MARGINS.left - MARGINS.right;

const border = { style: BorderStyle.SINGLE, size: 1, color: "000000" };
const borders = {
  top: border,
  bottom: border,
  left: border,
  right: border,
};

const chapters = [
  {
    key: "ch1",
    file: path.join(baseDir, "Раздел_1_Анализ_проблемы_и_требования.md"),
    figureMap: {
      "Рисунок 1 — Переход от разрозненного учёта к централизованной ИАС":
        "fig_1_1_transition_to_ias.png",
      "Рисунок 2 — Жизненный цикл актива (учёт технических средств)":
        "fig_1_2_asset_lifecycle.png",
      "Рисунок 3 — Жизненный цикл заявки Help Desk":
        "fig_1_3_helpdesk_lifecycle.png",
      "Рисунок 4 — Ключевые сущности предметной области и связи между ними":
        "fig_1_4_domain_entities_er.png",
      "Рисунок 5 — Распределение базовых сценариев по ролям пользователей":
        "fig_1_5_roles_and_scenarios.png",
    },
    tableMap: {
      "Таблица 1 — Сопоставление аналогов применительно к задаче учёта ТС и Help Desk":
        "Таблица 1.1 — Сопоставление аналогов применительно к задаче учёта ТС и Help Desk",
      "Таблица 2 — Сравнение проектных подходов для прототипа ИАС":
        "Таблица 1.2 — Сравнение проектных подходов для прототипа ИАС",
    },
  },
  {
    key: "ch2",
    file: path.join(baseDir, "Раздел_2_Архитектурное_проектирование.md"),
    figureMap: {
      "Рисунок 1 — Многослойная клиент-серверная архитектура прототипа ИАС":
        "fig_2_1_layered_architecture.png",
      "Рисунок 2 — Компонентная структура прототипа ИАС":
        "fig_2_2_component_structure.png",
      "Рисунок 3 — Схема развёртывания прототипа":
        "fig_2_3_deployment_scheme.png",
      "Рисунок 4 — Логическая модель данных (ключевые сущности и связи)":
        "fig_2_4_logical_data_model.png",
      "Рисунок 5 — Карта основных экранов и переходов в интерфейсе":
        "fig_2_5_ui_navigation_map.png",
    },
    tableMap: {
      "Таблица 3 — Сопоставление архитектурных вариантов для прототипа ИАС":
        "Таблица 2.1 — Сопоставление архитектурных вариантов для прототипа ИАС",
    },
  },
];

function stripMarkdownTail(text) {
  const marker = "\n## Рекомендуемые иллюстрации для раздела ";
  const idx = text.indexOf(marker);
  if (idx !== -1) {
    return text.slice(0, idx).trim() + "\n";
  }
  return text;
}

function normalizeText(text, tableMap) {
  let normalized = stripMarkdownTail(text)
    .replace(/\n---\n/g, "\n\n")
    .replace(/\r\n/g, "\n");

  for (const [from, to] of Object.entries(tableMap)) {
    normalized = normalized.replaceAll(from, to);
  }
  return normalized;
}

function parseInline(text) {
  const runs = [];
  const pattern = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`)/g;
  let lastIndex = 0;
  for (const match of text.matchAll(pattern)) {
    const index = match.index ?? 0;
    if (index > lastIndex) {
      runs.push(
        new TextRun({
          text: text.slice(lastIndex, index),
          font: "Times New Roman",
          size: 28,
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
          size: 28,
        }),
      );
    } else if (token.startsWith("*")) {
      runs.push(
        new TextRun({
          text: token.slice(1, -1),
          italics: true,
          font: "Times New Roman",
          size: 28,
        }),
      );
    } else {
      runs.push(
        new TextRun({
          text: token.slice(1, -1),
          font: "Courier New",
          size: 24,
        }),
      );
    }
    lastIndex = index + token.length;
  }
  if (lastIndex < text.length) {
    runs.push(
      new TextRun({
        text: text.slice(lastIndex),
        font: "Times New Roman",
        size: 28,
      }),
    );
  }
  return runs.length
    ? runs
    : [new TextRun({ text, font: "Times New Roman", size: 28 })];
}

function makeParagraph(text, options = {}) {
  return new Paragraph({
    children: parseInline(text),
    alignment: options.alignment ?? AlignmentType.JUSTIFIED,
    spacing: options.spacing ?? { after: 120, line: 360 },
    indent: options.indent ?? { firstLine: 709 },
    pageBreakBefore: options.pageBreakBefore ?? false,
  });
}

function makeHeading(text, level, pageBreakBefore = false) {
  return new Paragraph({
    heading: level,
    pageBreakBefore,
    children: [
      new TextRun({
        text,
        font: "Times New Roman",
      }),
    ],
  });
}

function makeCaption(text, kind) {
  return new Paragraph({
    children: parseInline(text),
    alignment: AlignmentType.CENTER,
    spacing: { before: 60, after: 120, line: 360 },
    indent: { firstLine: 0 },
    style: kind === "figure" ? "Caption" : "Caption",
  });
}

function fitImage(filePath) {
  const data = fs.readFileSync(filePath);
  // Conservative sizing for A4 text width.
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 60, after: 60 },
    children: [
      new ImageRun({
        type: "png",
        data,
        transformation: { width: 520, height: 320 },
        altText: {
          title: path.basename(filePath),
          description: path.basename(filePath),
          name: path.basename(filePath),
        },
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
    .map((cell) => cell.trim());
}

function makeTable(lines) {
  const rows = lines
    .map(splitTableRow)
    .filter((row, idx) => idx !== 1 && row.some((cell) => cell && !/^[-:]+$/.test(cell)));
  if (!rows.length) {
    return null;
  }

  const colCount = rows[0].length;
  const colWidth = Math.floor(CONTENT_WIDTH / colCount);

  return new Table({
    width: { size: CONTENT_WIDTH, type: WidthType.DXA },
    columnWidths: Array.from({ length: colCount }, () => colWidth),
    rows: rows.map((row, rowIndex) =>
      new TableRow({
        children: row.map(
          (cell) =>
            new TableCell({
              borders,
              width: { size: colWidth, type: WidthType.DXA },
              shading:
                rowIndex === 0
                  ? { fill: "EDEDED", type: ShadingType.CLEAR }
                  : undefined,
              margins: { top: 80, bottom: 80, left: 120, right: 120 },
              children: [
                new Paragraph({
                  children: parseInline(cell),
                  alignment: AlignmentType.LEFT,
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

function parseBlocks(text, chapter) {
  const lines = normalizeText(text, chapter.tableMap).split("\n");
  const blocks = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i].trim();

    if (!line) {
      i += 1;
      continue;
    }

    if (/^#\s+/.test(line)) {
      blocks.push({ type: "h1", text: line.replace(/^#\s+/, "") });
      i += 1;
      continue;
    }
    if (/^##\s+/.test(line)) {
      blocks.push({ type: "h2", text: line.replace(/^##\s+/, "") });
      i += 1;
      continue;
    }
    if (/^###\s+/.test(line)) {
      blocks.push({ type: "h3", text: line.replace(/^###\s+/, "") });
      i += 1;
      continue;
    }
    if (/^\|/.test(line)) {
      const tableLines = [];
      while (i < lines.length && /^\|/.test(lines[i].trim())) {
        tableLines.push(lines[i].trim());
        i += 1;
      }
      blocks.push({ type: "table", lines: tableLines });
      continue;
    }
    if (/^- /.test(line)) {
      const items = [];
      while (i < lines.length && /^- /.test(lines[i].trim())) {
        items.push(lines[i].trim().replace(/^- /, ""));
        i += 1;
      }
      blocks.push({ type: "list", items });
      continue;
    }
    const figureMatch = line.match(/^\*\*(Рисунок .*?)\*\*/);
    if (figureMatch) {
      const rawCaption = figureMatch[1];
      const mappedFile = chapter.figureMap[rawCaption];
      if (mappedFile) {
        const normalizedCaption = rawCaption
          .replace(/^Рисунок 1 —/, chapter.key === "ch1" ? "Рисунок 1.1 —" : "Рисунок 2.1 —")
          .replace(/^Рисунок 2 —/, chapter.key === "ch1" ? "Рисунок 1.2 —" : "Рисунок 2.2 —")
          .replace(/^Рисунок 3 —/, chapter.key === "ch1" ? "Рисунок 1.3 —" : "Рисунок 2.3 —")
          .replace(/^Рисунок 4 —/, chapter.key === "ch1" ? "Рисунок 1.4 —" : "Рисунок 2.4 —")
          .replace(/^Рисунок 5 —/, chapter.key === "ch1" ? "Рисунок 1.5 —" : "Рисунок 2.5 —");
        blocks.push({
          type: "figure",
          caption: normalizedCaption,
          file: path.join(imagesDir, mappedFile),
        });
      }
      i += 1;
      continue;
    }
    const tableCaptionMatch = line.match(/^\*\*(Таблица .*?)\*\*/);
    if (tableCaptionMatch) {
      blocks.push({ type: "tableCaption", text: tableCaptionMatch[1] });
      i += 1;
      continue;
    }

    const paraLines = [line];
    i += 1;
    while (i < lines.length) {
      const next = lines[i].trim();
      if (
        !next ||
        /^#/.test(next) ||
        /^\|/.test(next) ||
        /^- /.test(next) ||
        /^\*\*(Рисунок|Таблица)/.test(next)
      ) {
        break;
      }
      paraLines.push(next);
      i += 1;
    }
    blocks.push({ type: "paragraph", text: paraLines.join(" ") });
  }

  return blocks;
}

function buildChildren() {
  const children = [];
  let chapterIndex = 0;

  for (const chapter of chapters) {
    const text = fs.readFileSync(chapter.file, "utf8");
    const blocks = parseBlocks(text, chapter);

    for (const block of blocks) {
      if (block.type === "h1") {
        children.push(makeHeading(block.text, HeadingLevel.HEADING_1, chapterIndex > 0));
      } else if (block.type === "h2") {
        children.push(makeHeading(block.text, HeadingLevel.HEADING_2));
      } else if (block.type === "h3") {
        children.push(makeHeading(block.text, HeadingLevel.HEADING_3));
      } else if (block.type === "paragraph") {
        children.push(makeParagraph(block.text));
      } else if (block.type === "list") {
        for (const item of block.items) {
          children.push(
            new Paragraph({
              numbering: { reference: "bullets", level: 0 },
              children: parseInline(item),
              spacing: { after: 80, line: 360 },
            }),
          );
        }
      } else if (block.type === "tableCaption") {
        children.push(makeCaption(block.text, "table"));
      } else if (block.type === "table") {
        const table = makeTable(block.lines);
        if (table) {
          children.push(table);
        }
      } else if (block.type === "figure") {
        children.push(fitImage(block.file));
        children.push(makeCaption(block.caption, "figure"));
      }
    }
    chapterIndex += 1;
  }

  children.push(new Paragraph({ children: [new PageBreak()] }));
  return children;
}

async function main() {
  const children = buildChildren();

  const doc = new Document({
    styles: {
      default: {
        document: {
          run: {
            font: "Times New Roman",
            size: 28,
          },
          paragraph: {
            spacing: { line: 360, after: 120 },
          },
        },
      },
      paragraphStyles: [
        {
          id: "Heading1",
          name: "Heading 1",
          basedOn: "Normal",
          next: "Normal",
          quickFormat: true,
          run: { size: 32, bold: true, font: "Times New Roman" },
          paragraph: {
            spacing: { before: 240, after: 240 },
            alignment: AlignmentType.CENTER,
            outlineLevel: 0,
          },
        },
        {
          id: "Heading2",
          name: "Heading 2",
          basedOn: "Normal",
          next: "Normal",
          quickFormat: true,
          run: { size: 30, bold: true, font: "Times New Roman" },
          paragraph: {
            spacing: { before: 180, after: 120 },
            alignment: AlignmentType.LEFT,
            outlineLevel: 1,
          },
        },
        {
          id: "Heading3",
          name: "Heading 3",
          basedOn: "Normal",
          next: "Normal",
          quickFormat: true,
          run: { size: 28, bold: true, font: "Times New Roman" },
          paragraph: {
            spacing: { before: 120, after: 80 },
            alignment: AlignmentType.LEFT,
            outlineLevel: 2,
          },
        },
        {
          id: "Caption",
          name: "Caption",
          basedOn: "Normal",
          next: "Normal",
          quickFormat: true,
          run: { size: 24, italic: false, font: "Times New Roman" },
          paragraph: {
            spacing: { before: 60, after: 120 },
            alignment: AlignmentType.CENTER,
          },
        },
      ],
    },
    numbering: {
      config: [
        {
          reference: "bullets",
          levels: [
            {
              level: 0,
              format: LevelFormat.BULLET,
              text: "•",
              alignment: AlignmentType.LEFT,
              style: { paragraph: { indent: { left: 720, hanging: 360 } } },
            },
          ],
        },
      ],
    },
    sections: [
      {
        properties: {
          page: {
            size: { width: A4_WIDTH, height: A4_HEIGHT },
            margin: MARGINS,
          },
        },
        footers: {
          default: new Footer({
            children: [
              new Paragraph({
                alignment: AlignmentType.CENTER,
                children: [
                  new TextRun({ text: "Страница ", font: "Times New Roman", size: 24 }),
                  new TextRun({ children: [PageNumber.CURRENT], font: "Times New Roman", size: 24 }),
                ],
              }),
            ],
          }),
        },
        children,
      },
    ],
  });

  const buffer = await Packer.toBuffer(doc);
  const outPath = path.join(outDir, "ВКР_главы_1_2_DOCX_skill_сборка.docx");
  fs.writeFileSync(outPath, buffer);
  process.stdout.write(`${outPath}\n`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
