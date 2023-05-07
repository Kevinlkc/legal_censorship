# legal_censorship
### Background
China started publishing the universe of court verdicts as part of their legal reform since 2013. This endeavor is widely acknowledged as a cruicial step towards legal transparency, justice, and government accountability. However, starting from 2021, the government seems to be intentionally rolling back the commitment. Not only do we observe a huge dip in the total # of published verdicts, we also observe a considerable number of cases where previous court verdicts have been retracted. Out of the 80 million civil lawsuits published, over 2.5 million are retracted from the official website.

<img width=500 src="https://user-images.githubusercontent.com/53916529/236542868-c449d13c-7778-4612-8c6f-6db0c2d1ae03.png">

### Research question:
We're interested in understanding this unique phenomenon of legal censorship. Specifically,
- What kind of legal documents got censored?
- Why does local courts / government have the incentive to censor?
- What's the economic impact of such censorship?

### Roadmap:
#### Main section 1: Predictors of legal censorship
- Main assumption: Connections, fiscal revenue and investment
  - First cut: Local vs. Non-local firms;
  - State-owned enterprises vs. private companies;
  - We could also measure firm-to-province connection by previous government investments;
  - For the subset of listed firms, we may follow CLFPD's strategy to measure annual level board of directors' political connection.
  - Court cases that involves firms that contributes to a larger share of local fiscal revenue are more likely to get censored.
- Other explanatory factors: 
  - "Politically sensitive" keywords
  - Social unrest
  - National security and international relations

#### Main section 2: Incentives to censor
- Firm-level regression: Did court verdict removal help those firms attract more investment?
  - Heterogeneity on # of previous cases
  - Heterogeneity on type of court cases
- County-level regression: Did counties with higher court-verdict removal rates attract more investment / fiscal revenue (or its first derivative)?
  - Or maybe it's just a zero-sum game, and legal censorship merely re-allocates the investment within the pool.
- Other miscellaneous incentives: Judge / Court level promotion?

#### (Optional) Main section 3: downside of censorship?
