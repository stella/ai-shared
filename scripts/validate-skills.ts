#!/usr/bin/env bun

import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative, resolve } from "node:path";

const SKILL_NAME_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/u;
const FRONTMATTER_MARKER = "---";

type SkillMetadata = Record<string, unknown>;

export type ValidationError = {
  file: string;
  message: string;
};

const errorMessage = (error: unknown) =>
  error instanceof Error ? error.message : String(error);

const formatPath = (root: string, file: string) => relative(root, file) || ".";

const markdownFiles = (directory: string): string[] => {
  const files: string[] = [];

  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const entryPath = join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...markdownFiles(entryPath));
    } else if (entry.isFile() && entry.name.toLowerCase().endsWith(".md")) {
      files.push(entryPath);
    }
  }

  return files;
};

const isSkillMetadata = (value: unknown): value is SkillMetadata =>
  value !== null && typeof value === "object" && !Array.isArray(value);

const parseFrontmatter = (source: string) => {
  const lines = source.split(/\r?\n/u);
  if (lines.at(0) !== FRONTMATTER_MARKER) {
    throw new Error("SKILL.md must start with YAML frontmatter");
  }

  const closingIndex = lines.findIndex(
    (line, index) => index > 0 && line === FRONTMATTER_MARKER,
  );
  if (closingIndex === -1) {
    throw new Error("YAML frontmatter is not closed");
  }

  let metadata: unknown;
  try {
    metadata = Bun.YAML.parse(lines.slice(1, closingIndex).join("\n"));
  } catch (error) {
    throw new Error("invalid YAML frontmatter: " + errorMessage(error));
  }

  if (!isSkillMetadata(metadata)) {
    throw new Error("YAML frontmatter must be a mapping");
  }

  return {
    metadata,
    body: lines.slice(closingIndex + 1).join("\n"),
  };
};

const validateMetadata = (
  skillDirectoryName: string,
  skillFile: string,
  metadata: SkillMetadata,
): ValidationError[] => {
  const errors: ValidationError[] = [];
  const skillName = metadata.name;
  if (
    typeof skillName !== "string" ||
    skillName.length > 64 ||
    !SKILL_NAME_PATTERN.test(skillName)
  ) {
    errors.push({
      file: skillFile,
      message:
        "name must be a lowercase alphanumeric skill name with hyphens, at most 64 characters",
    });
  } else if (skillName !== skillDirectoryName) {
    errors.push({
      file: skillFile,
      message:
        "name must match the skill directory (" + skillDirectoryName + ")",
    });
  }

  if (
    typeof metadata.description !== "string" ||
    metadata.description.trim().length === 0
  ) {
    errors.push({
      file: skillFile,
      message: "description must be a nonempty string",
    });
  }

  return errors;
};

const isExternalTarget = (target: string) =>
  target.startsWith("//") || /^[a-z][a-z\d+.-]*:/iu.test(target);

const localTargetPath = (target: string, sourceFile: string) => {
  const withoutFragment = target.split(/[?#]/u, 1).at(0) ?? "";
  if (withoutFragment.length === 0 || isExternalTarget(withoutFragment)) {
    return null;
  }

  let decodedTarget: string;
  try {
    decodedTarget = decodeURIComponent(withoutFragment);
  } catch {
    decodedTarget = withoutFragment;
  }

  return resolve(join(sourceFile, ".."), decodedTarget);
};

type ValidateMarkdownReferencesOptions = {
  skillDirectory: string;
  skillBody: string;
};

const validateMarkdownReferences = ({
  skillDirectory,
  skillBody,
}: ValidateMarkdownReferencesOptions): ValidationError[] => {
  const errors: ValidationError[] = [];

  for (const sourceFile of markdownFiles(skillDirectory)) {
    let source: string;
    try {
      source =
        sourceFile === join(skillDirectory, "SKILL.md")
          ? skillBody
          : readFileSync(sourceFile, "utf8");
    } catch (error) {
      errors.push({
        file: sourceFile,
        message: "could not read Markdown: " + errorMessage(error),
      });
      continue;
    }

    const checkTarget = (target: string, kind: "link" | "image") => {
      const targetPath = localTargetPath(target, sourceFile);
      if (
        targetPath === null ||
        statSync(targetPath, { throwIfNoEntry: false }) !== undefined
      ) {
        return;
      }

      errors.push({
        file: sourceFile,
        message: "broken local " + kind + ' target "' + target + '"',
      });
    };

    try {
      Bun.markdown.render(source, {
        link: (_children, { href }) => {
          checkTarget(href, "link");
          return "";
        },
        image: (_children, { src }) => {
          checkTarget(src, "image");
          return "";
        },
      });
    } catch (error) {
      errors.push({
        file: sourceFile,
        message: "could not parse Markdown: " + errorMessage(error),
      });
    }
  }

  return errors;
};

export const validateSkills = (rootInput: string): ValidationError[] => {
  const root = resolve(rootInput);
  if (statSync(root, { throwIfNoEntry: false })?.isDirectory() !== true) {
    return [{ file: rootInput, message: "skill root must be a directory" }];
  }

  const errors: ValidationError[] = [];
  for (const entry of readdirSync(root, { withFileTypes: true })) {
    if (!entry.isDirectory() || entry.name.startsWith(".")) {
      continue;
    }

    const skillDirectory = join(root, entry.name);
    const skillFile = join(skillDirectory, "SKILL.md");
    if (statSync(skillFile, { throwIfNoEntry: false })?.isFile() !== true) {
      errors.push({
        file: skillDirectory,
        message: "directory-format skill must contain SKILL.md",
      });
      continue;
    }

    let skillBody = "";
    try {
      const parsedSkill = parseFrontmatter(readFileSync(skillFile, "utf8"));
      errors.push(
        ...validateMetadata(entry.name, skillFile, parsedSkill.metadata),
      );
      skillBody = parsedSkill.body;
    } catch (error) {
      errors.push({ file: skillFile, message: errorMessage(error) });
    }
    errors.push(...validateMarkdownReferences({ skillDirectory, skillBody }));
  }

  return errors.map((error) => ({
    ...error,
    file: formatPath(root, error.file),
  }));
};

const main = () => {
  const rootInput = Bun.argv.at(2) ?? "skills";
  const errors = validateSkills(rootInput);
  if (errors.length === 0) {
    console.log("Validated skills in " + rootInput);
    return;
  }

  for (const error of errors) {
    console.error(error.file + ": " + error.message);
  }
  process.exitCode = 1;
};

if (import.meta.main) {
  main();
}
