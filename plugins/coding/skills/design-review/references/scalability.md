# Scalability checks

Scale problems are design problems: by the time they show up as incidents, the fix is a redesign. Start by naming the expected load, then check each area. If nobody can say what the load is, that is the first finding.

## Load and growth

- What are today's numbers (requests, events, records, users, tenants) and the expected numbers in 12 months?
- Which dimension grows fastest? Design for that one.
- What is the peak-to-average ratio? Batch jobs, month-end and retries all create spikes.

## Bottlenecks

- What is the single slowest or most contended component on the hot path?
- Is there one database, queue partition, lock or external API that every request touches?
- Does any operation scale with total data size instead of request size (full scans, unbounded lists, "load everything then filter")?

## Statelessness and horizontal scale

- Can more instances be added without coordination? Where does state live?
- Do instances share anything in memory or on local disk that breaks with two copies (see failure class 3)?
- Are scheduled jobs safe when two instances both think they should run?

## Data

- How is data partitioned, and will the partition key stay balanced as it grows (hot tenants, hot dates)?
- Are queries backed by indexes that match their filters and sort order?
- Is there a retention or archiving plan, or does every table grow forever?
- Are reads that tolerate staleness served from caches or replicas (see failure class 13)?

## Back-pressure and failure modes

- What happens when a downstream dependency slows down: do requests queue without limit?
- Are there timeouts, retries with backoff and jitter, and circuit breakers?
- Can a retry storm amplify an outage? Are retries idempotent (see failure class 2)?
- Is work that can be async moved off the request path, with a dead-letter path for failures?

## External limits

- Which cloud, API or vendor quotas apply (rate limits, connection limits, account quotas)?
- What happens when one is hit, and does anything alert before it is?

## Cost

- Does cost grow linearly with load, or faster?
- Is there any per-request cost (paid API calls, LLM tokens, egress) that needs a budget or cap?

## Observability at scale

- Are latency, error rate, saturation and queue depth measured for each component?
- Can you tell which tenant or caller is responsible for load?
