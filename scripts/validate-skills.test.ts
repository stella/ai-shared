import { mkdir, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, describe, expect, test } from "bun:test";
import { validateSkills } from "./validate-skills";

const temporaryDirectories: string[] = [];

afterEach(async () => {
  await Promise.all(
    temporaryDirectories
      .splice(0)
      .map((directory) => rm(directory, { recursive: true, force: true })),
  );
});

const createSkillRoot = async (skillName = "valid-skill") => {
  const root = await mkdtemp(join(tmpdir(), "validate-skills-"));
  temporaryDirectories.push(root);
  await mkdir(join(root, skillName, "docs"), { recursive: true });
  return root;
};

const writeSkill = async (
  root: string,
  contents: string,
  skillName = "valid-skill",
) => {
  await writeFile(join(root, skillName, "SKILL.md"), contents);
};

describe("validateSkills", () => {
  test("accepts multiline and quoted metadata, reference links, and nested docs", async () => {
    const root = await createSkillRoot();
    await writeSkill(
      root,
      [
        "---",
        "name: valid-skill",
        "description: >",
        '  A multiline description with a quoted "value" and [an example](docs/missing.md).',
        'argument-hint: "[target]"',
        "---",
        "",
        "# Valid skill",
        "",
        "[guide][guide]",
        "",
        "[guide]: docs/guide.md",
        "",
        "[section](#valid-skill)",
        "[external](https://example.com/missing.md)",
        "[email](mailto:docs@example.com)",
        "![remote](https://example.com/missing.png)",
        "",
      ].join("\n"),
    );
    const fence = String.fromCharCode(96).repeat(3);
    await writeFile(
      join(root, "valid-skill", "docs", "guide.md"),
      [
        "![diagram](diagram.svg)",
        "",
        fence + "md",
        "[ignored](missing.md)",
        fence,
        "",
      ].join("\n"),
    );
    await writeFile(join(root, "valid-skill", "docs", "diagram.svg"), "svg");

    expect(validateSkills(root)).toEqual([]);
  });

  test("reports invalid metadata and a missing local target", async () => {
    const root = await createSkillRoot("Bad_Skill");
    await writeSkill(
      root,
      [
        "---",
        "name: Bad_Skill",
        'description: "   "',
        "---",
        "",
        "[missing](docs/missing.md)",
        "",
      ].join("\n"),
      "Bad_Skill",
    );

    expect(validateSkills(root)).toEqual([
      expect.objectContaining({
        message:
          "name must be a lowercase alphanumeric skill name with hyphens, at most 64 characters",
      }),
      expect.objectContaining({
        message: "description must be a nonempty string",
      }),
      expect.objectContaining({
        message: 'broken local link target "docs/missing.md"',
      }),
    ]);
  });

  test("reports missing frontmatter and broken images in nested Markdown", async () => {
    const root = await createSkillRoot();
    await writeSkill(root, "# Missing frontmatter\n");
    await writeFile(
      join(root, "valid-skill", "docs", "guide.md"),
      "![missing](missing.png)\n",
    );

    expect(validateSkills(root)).toEqual([
      expect.objectContaining({
        message: "SKILL.md must start with YAML frontmatter",
      }),
      expect.objectContaining({
        message: 'broken local image target "missing.png"',
      }),
    ]);
  });

  test("rejects missing, non-string, malformed, and mismatched metadata", async () => {
    const cases = [
      {
        directory: "missing-fields",
        frontmatter: ["---", "other: value", "---", ""],
        messages: [
          "name must be a lowercase alphanumeric skill name with hyphens, at most 64 characters",
          "description must be a nonempty string",
        ],
      },
      {
        directory: "non-string-fields",
        frontmatter: ["---", "name: 42", "description: []", "---", ""],
        messages: [
          "name must be a lowercase alphanumeric skill name with hyphens, at most 64 characters",
          "description must be a nonempty string",
        ],
      },
      {
        directory: "directory-mismatch",
        frontmatter: [
          "---",
          "name: another-skill",
          "description: A valid description.",
          "---",
          "",
        ],
        messages: ["name must match the skill directory (directory-mismatch)"],
      },
      {
        directory: "malformed-yaml",
        frontmatter: ["---", "name: [", "description: broken", "---", ""],
        messages: ["invalid YAML frontmatter"],
      },
    ];

    for (const testCase of cases) {
      const root = await createSkillRoot(testCase.directory);
      await writeSkill(
        root,
        testCase.frontmatter.concat("# Body\n").join("\n"),
        testCase.directory,
      );

      const messages = validateSkills(root).map((error) => error.message);
      for (const message of testCase.messages) {
        expect(messages.some((actual) => actual.startsWith(message))).toBe(
          true,
        );
      }
    }
  });

  test("rejects a missing SKILL.md and a missing skill root", async () => {
    const root = await createSkillRoot();
    expect(validateSkills(root)).toEqual([
      {
        file: "valid-skill",
        message: "directory-format skill must contain SKILL.md",
      },
    ]);

    expect(validateSkills(join(root, "missing-root"))).toEqual([
      {
        file: join(root, "missing-root"),
        message: "skill root must be a directory",
      },
    ]);
  });

  test("resolves encoded local targets and reports broken reference links", async () => {
    const root = await createSkillRoot();
    await writeSkill(
      root,
      [
        "---",
        "name: valid-skill",
        "description: A valid description.",
        "---",
        "",
        "[encoded](docs/encoded%20file.md?view=1#section)",
        "![encoded](docs/image%20file.svg#preview)",
        "[section](#heading)",
        "[external](https://example.com/missing.md)",
        "[missing][missing]",
        "",
        "[missing]: docs/missing.md",
        "",
      ].join("\n"),
    );
    await writeFile(
      join(root, "valid-skill", "docs", "encoded file.md"),
      "# Heading\n",
    );
    await writeFile(join(root, "valid-skill", "docs", "image file.svg"), "svg");

    expect(validateSkills(root)).toEqual([
      {
        file: "valid-skill/SKILL.md",
        message: 'broken local link target "docs/missing.md"',
      },
    ]);
  });
});
