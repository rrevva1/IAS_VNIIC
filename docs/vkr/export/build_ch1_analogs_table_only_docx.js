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

const outPath = path.join(
  __dirname,
  "docx",
  "ВКР_глава_1_таблица_1_2а_сравнение_аналогов.docx",
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

const TABLE_ROWS = [
  [
    "Решение",
    "Происхождение и модель поставки",
    "Лицензирование и порог входа",
    "Контур учёта активов",
    "Контур Help Desk",
    "Адаптация под регламенты предприятия",
    "Основные ограничения для рассматриваемой задачи",
  ],
  [
    "Naumen Service Desk + Naumen ITAM",
    "Российское enterprise-решение, on-premise / корпоративное внедрение",
    "Коммерческая модель, высокий порог входа",
    "Развитый",
    "Развитый",
    "Возможна, но требует проекта внедрения",
    "Высокая стоимость, избыточность, зависимость от вендора",
  ],
  [
    "SimpleOne ITSM / ITAM",
    "Российская ESM/ITSM-платформа, корпоративное развёртывание",
    "Коммерческая модель, высокий или средне-высокий порог входа",
    "Развитый через ITAM/CMDB",
    "Развитый",
    "Высокая гибкость, но требуется настройка модели и процессов",
    "Корпоративная сложность, затраты на адаптацию и сопровождение",
  ],
  [
    "Astra Automation + ACM",
    "Российская экосистема автоматизации и управления конфигурациями",
    "Коммерческая модель, средне-высокий порог входа",
    "Развитый по линии инвентаризации и конфигураций",
    "Частично, требует дополнительного сервисного контура",
    "Высокая совместимость с отечественной инфраструктурой",
    "Нет прямого единого контура заявок и учёта ТС в одной прикладной модели",
  ],
  [
    "ИнфраМенеджер",
    "Российская ITSM/ITAM/CMDB-платформа, on-premise",
    "Коммерческая модель, средний или средне-высокий порог входа",
    "Развитый",
    "Развитый",
    "Высокая предметная близость, но нужна настройка",
    "Требуется адаптация под локальные справочники и регламенты предприятия",
  ],
  [
    "ITSM 365",
    "Российское сервисное решение, облачное/гибкое внедрение",
    "Более доступный порог входа по сравнению с enterprise-платформами",
    "Базовый или средний, зависит от конфигурации",
    "Развитый",
    "Высокая гибкость сервисных процессов",
    "Сильнее в service desk, чем в глубоком корпоративном учёте ТС",
  ],
  [
    "GLPI",
    "Зарубежное open-source решение, self-hosted",
    "Низкий лицензионный барьер",
    "Развитый",
    "Развитый",
    "Возможна через настройку и плагины",
    "Не соответствует приоритету отечественного ПО, требует локальной адаптации",
  ],
  [
    "Проектируемый прототип ИАС",
    "Разрабатываемое решение под условия конкретного предприятия",
    "Затраты ограничены рамками прототипа и целевым функционалом",
    "Формируется по требованиям предприятия",
    "Формируется по требованиям предприятия",
    "Максимальная, так как структура закладывается под внутренние регламенты",
    "Необходимость собственной разработки и последующего развития",
  ],
];

function buildTable() {
  const tableWidth = LANDSCAPE_CONTENT_WIDTH;
  const widths = [1900, 2200, 2200, 1600, 1600, 2400, tableWidth - 11900];

  return new Table({
    width: { size: tableWidth, type: WidthType.DXA },
    columnWidths: widths,
    rows: TABLE_ROWS.map((cells, rowIndex) =>
      new TableRow({
        children: cells.map((cell, cellIndex) =>
          new TableCell({
            borders,
            width: {
              size: widths[cellIndex] ?? Math.floor(tableWidth / cells.length),
              type: WidthType.DXA,
            },
            margins: { top: 100, bottom: 100, left: 100, right: 100 },
            shading: rowIndex === 0 ? { fill: "D9EAF7" } : undefined,
            children: [
              new Paragraph({
                children: [
                  new TextRun({
                    text: cell,
                    font: "Times New Roman",
                    size: 28,
                  }),
                ],
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

async function main() {
  const doc = new Document({
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
                  new TextRun({
                    children: [PageNumber.CURRENT],
                    font: "Times New Roman",
                    size: 24,
                  }),
                ],
              }),
            ],
          }),
        },
        children: [
          new Paragraph({
            heading: HeadingLevel.HEADING_1,
            spacing: { before: 0, after: 120 },
            children: [
              new TextRun({
                text: "Таблица 1.2а — Сравнение реальных аналогов и проектируемого прототипа ИАС",
                font: "Times New Roman",
              }),
            ],
          }),
          buildTable(),
        ],
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
