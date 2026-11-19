# 首批 10 条语录核验样本

更新日期：2026-10-29

## 1. 本轮结论

- 英文侧已用 Foreign Languages Press, Peking 1965 年扫描版逐页定位 10 条样本。
- 中文侧已用共产党员网官方正文或带书目信息的官方文章交叉定位。
- 由于尚未取得并登记人民出版社 1991 年第 2 版完整底本，本轮没有任何一条升级为 `cn_verified` 或 `approved`。
- 附件设计稿中的语录属于编辑性摘编。它不能被误记为底本中的连续原句，但在完成片段溯源、语义审校和英文编辑翻译后可以进入正式资源，不要求为了使用它而恢复完整原句。

## 2. 样本清单

| ID | 中文候选 | 英文底本原文 | 篇目与英文印刷页 | 当前状态 |
|---|---|---|---|---|
| `SWM-001-001` | 谁是我们的敌人？谁是我们的朋友？这个问题是革命的首要问题。 | Who are our enemies? Who are our friends? This is a question of the first importance for the revolution. | 《中国社会各阶级的分析》/ `Analysis of the Classes in Chinese Society`, Vol. I, p. 13 | `candidate`；待中文 1991 版页码核验 |
| `SWM-001-002` | 真理的标准只能是社会的实践。 | Only social practice can be the criterion of truth. | 《实践论》/ `On Practice`, Vol. I, p. 297 | `candidate`；待中文 1991 版页码核验 |
| `SWM-002-001` | 武器是战争的重要的因素，但不是决定的因素，决定的因素是人不是物。 | Weapons are an important factor in war, but not the decisive factor; it is people, not things, that are decisive. | 《论持久战》/ `On Protracted War`, Vol. II, p. 143 | `candidate`；中文官方正文已定位，待纸本页码 |
| `SWM-002-002` | 我们大家要学习他毫无自私自利之心的精神。 | We must all learn the spirit of absolute selflessness from him. | 《纪念白求恩》/ `In Memory of Norman Bethune`, Vol. II, p. 338 | `candidate`；待中文 1991 版页码核验 |
| `SWM-003-001` | 群众是真正的英雄，而我们自己则往往是幼稚可笑的，不了解这一点，就不能得到起码的知识。 | It has to be understood that the masses are the real heroes, while we ourselves are often childish and ignorant, and without this understanding it is impossible to acquire even the most rudimentary knowledge. | 《〈农村调查〉的序言和跋》/ `Preface and Postscript to Rural Surveys`, Vol. III, p. 12 | `candidate`；官方文章给出中文 1991 版 p. 790，仍待底本复核 |
| `SWM-003-002` | 没有调查，没有发言权。 | No investigation, no right to speak. | 《〈农村调查〉的序言和跋》/ `Preface and Postscript to Rural Surveys`, Vol. III, p. 13 | `candidate`；同一句也见于早期文章，必须固定本条采用的篇目与上下文 |
| `SWM-003-003` | 人民，只有人民，才是创造世界历史的动力。 | The people, and the people alone, are the motive force of world history. | 《论联合政府》/ `On Coalition Government`, Vol. III, p. 257 | `candidate`；官方文章给出中文 1991 版 p. 1031，仍待底本复核 |
| `SWM-003-004` | 如果真想做宣传，就要看对象，否则就等于下决心不要人看，不要人听。 | If you really want to do propaganda, you must consider your audience; otherwise, you are in effect resolving not to be read or listened to by anyone. | 摘编自《反对党八股》/ based on `Oppose Stereotyped Party Writing`, Vol. III, p. 59 | `candidate`；允许编辑性摘编，英文为基于权威片段的项目编辑译文 |
| `SWM-004-001` | 一切反动派都是纸老虎。 | All reactionaries are paper tigers. | 《和美国记者安娜·路易斯·斯特朗的谈话》/ `Talk with the American Correspondent Anna Louise Strong`, Vol. IV, p. 100 | `candidate`；中文官方正文已定位，待纸本页码 |
| `SWM-004-002` | 务必使同志们继续地保持谦虚、谨慎、不骄、不躁的作风，务必使同志们继续地保持艰苦奋斗的作风。 | The comrades must be taught to remain modest, prudent and free from arrogance and rashness in their style of work. The comrades must be taught to preserve the style of plain living and hard struggle. | 《在中国共产党第七届中央委员会第二次全体会议上的报告》/ `Report to the Second Plenary Session of the Seventh Central Committee of the Communist Party of China`, Vol. IV, p. 374 | `candidate`；中英文措辞范围需编辑复核，不能回译替代底本 |

## 3. 附件设计稿核验结果

设计稿文字：

> 如果真想做宣传，就要看对象，否则就等于下决心不要人看，不要人听。

权威篇目中的中文完整句：

> 共产党员如果真想做宣传，就要看对象，就要想一想自己的文章、演说、谈话、写字是给什么人看、给什么人听的，否则就等于下决心不要人看，不要人听。

识别结果：设计稿保留了“做宣传要看对象”与“不考虑对象就等于拒绝被阅读/倾听”两个核心部分，省略了特定主语和中间列举。组合后的核心含义与该段一致，可作为编辑性摘编使用。

正式记录方式：

1. `design_text_zh` 保存设计稿展示文字，不强制补省略号；
2. `source_fragments` 分别保存“如果真想做宣传，就要看对象”和结尾片段的底本位置；
3. 详情页展示完整出处，并说明“本页文字为摘编”；
4. 英文优先采用权威英译中的对应措辞，再按设计稿范围组合；完整英文标记为 `project_editorial_translation`；
5. 只有当组合后实质改变原意或找不到可靠出处时才阻塞。

该条在完成中文纸本页码、片段定位和二次语义审校前保持 `candidate`；`edited_or_noncontiguous_checked` 本身不构成阻塞原因。

## 4. 样本使用限制

- 本表是核验流程样本，不是可直接导入 App 的正式内容包。
- 中文页码、实际印次、核验人、二审人尚未齐全。
- “详细解读”尚未撰写；后续必须区分历史背景、通俗释义和项目编辑观点，不把编辑观点伪装成原作者原意。
- 365 条正式清单到位后，必须逐条走同一门禁，不允许因产品排期批量跳过。
