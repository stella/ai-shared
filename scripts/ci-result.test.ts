import { expect, test } from "bun:test";
import { YAML } from "bun";
import { readFileSync } from "node:fs";

type Workflow = {
  on?: Record<string, unknown>;
  jobs?: Record<
    string,
    {
      if?: string;
      needs?: string | string[];
    }
  >;
};

const readWorkflow = (path: string): Workflow =>
  YAML.parse(
    readFileSync(new URL(`../${path}`, import.meta.url), "utf8"),
  ) as Workflow;

test("ci-result covers every validation job", () => {
  const workflow = readWorkflow(".github/workflows/validate.yml");
  const jobs = workflow.jobs ?? {};
  const aggregate = jobs["ci-result"];
  const needs = Array.isArray(aggregate?.needs)
    ? aggregate.needs
    : [aggregate?.needs];
  const validationJobs = Object.keys(jobs).filter((job) => job !== "ci-result");

  expect(aggregate?.if).toBe("always()");
  expect(new Set(needs)).toEqual(new Set(validationJobs));
});

test("CI and CLA workflows run for merge groups", () => {
  const validate = readWorkflow(".github/workflows/validate.yml");
  const cla = readWorkflow(".github/workflows/cla.yml");

  expect(validate.on?.["merge_group"]).toMatchObject({
    types: ["checks_requested"],
  });
  expect(cla.on?.["merge_group"]).toMatchObject({
    types: ["checks_requested"],
  });
});
