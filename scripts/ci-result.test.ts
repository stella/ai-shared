import { YAML } from "bun";
import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";

type Job = {
  if?: string;
  needs?: string | string[];
};

type Workflow = {
  on?: Record<string, unknown>;
  jobs?: Record<string, Job>;
};

const readWorkflow = (path: string): Workflow =>
  YAML.parse(
    readFileSync(new URL(`../${path}`, import.meta.url), "utf8"),
  ) as Workflow;

const needsOf = (job: Job | undefined): string[] => {
  const needs = job?.needs;
  if (needs === undefined) {
    return [];
  }
  return typeof needs === "string" ? [needs] : [...needs];
};

test("ci-result covers every validation job", () => {
  const workflow = readWorkflow(".github/workflows/validate.yml");
  const jobs = workflow.jobs ?? {};
  const aggregate = jobs["ci-result"];
  const validationJobs = Object.keys(jobs).filter((job) => job !== "ci-result");

  expect(aggregate?.if).toBe("always()");
  expect(needsOf(aggregate).toSorted()).toEqual(validationJobs.toSorted());
});

test("CI and CLA workflows run for merge groups", () => {
  const validate = readWorkflow(".github/workflows/validate.yml");
  const cla = readWorkflow(".github/workflows/cla.yml");

  expect(validate.on?.["merge_group"]).toEqual({
    types: ["checks_requested"],
  });
  expect(cla.on?.["merge_group"]).toEqual({
    types: ["checks_requested"],
  });
});
