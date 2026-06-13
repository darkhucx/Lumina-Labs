---
title: "Making a vintage LLM from scratch"
source: "hn-frontpage"
author: "frontpage"
source_url: "https://crlf.link/log/entries/260525-1/"
date: 2026-06-12
lang: "unknown"
category: "hn"
tags: ["hn", "frontpage"]
status: published
---

# 从零开始制作复古LLM

在这篇博客中，我将分享我创建自己LLM的经历，这个LLM几乎是从零开始的，只用旧文本进行训练。

我制作了自己的基础训练和微调脚本、数据处理流程和自定义数据集。

（“几乎从零开始”意味着我使用了现有的编程语言和库，我没有用汇编语言编写，就像任何从零开始构建AI的人一样...）

该模型可以在HuggingFace上找到：https://huggingface.co/croqaz/vintage-LLM-340m-v1-base ;

所有代码都可以在此开源：https://github.com/croqaz/vintage-LLM ;

如果你想查看更大的复古模型，请看我的上一篇帖子：Vintage LLM models。

### 想法

三个月前二月底，我发现了一些Hayk Grigorian在Reddit上的帖子，他在其中描述了如何创建他的时间门控语言模型。我对此感到非常着迷。

仅用19世纪伦敦文本训练LLM，90GB数据集：

https://reddit.com/r/LocalLLaMA/comments/1pkpsee/training_an_llm_only_on_1800s_london_texts_90gb

仅用19世纪伦敦文本从零开始训练的LLM引发了1834年的真实抗议：

https://reddit.com/r/LocalLLaMA/comments/1mvnmjo/my_llm_trained_from_scratch_on_only_1800s_london

显然我阅读了其他制作自己LLM的人的帖子，但也许我还没有准备好自己动手，或者他们正在研究的模型不够有趣。无论如何，拥有我自己的维多利亚时代聊天机器人的想法……太史诗了！！

从那时起，我每天都在做我的“复古LLM”。没有例外。即使我生病了也是如此。

同时，许多更多的历史LLM也发布了，例如：Violet-1B4-Chat, Mr. Chatterbox, GPT-1900, Talkie和TypewriterLM-base。

### 问：为什么，在哪里和如何做？

**问：**

这是一个时间锁定的LLM/历史LLM，仅限英语，其知识截止日期是1900年。

（限制到特定年份容易出错，但我尽了最大的努力）。

它基于Llama架构，拥有340M (0.3B) 个参数。

**为什么？**

因为只有自己动手才能学到东西，而且这是一个超级有趣的项目。

**在哪里和如何做？**

我制作了自己的数据集、处理和训练代码。

代码是半“氛围编码”的，使用了我在VS-Code和PI（OpenRouter模型）上拥有的任何LLM。

我检查并验证了每一个函数，我深入理解了每一个代码文件在做什么。

数据集处理耗费了最多的时间，我尝试了各种无效的方法，浪费了大量时间。复杂的解决方案是最糟糕的……

我在自己的PC上处理了所有数据，并在我的PC上训练了LLM的较小版本（*Cachy OS Linux, AMD Ryzen 7 9700X CPU, 64GB RAM, Radeon RX 9070 16GB VRAM*）。

至于更大的340M模型，我是在RunPod、ThunderCompute和Vast.ai上训练的。如果在我自己的PC上训练，那将需要永恒的时间。

这个项目的总成本是：约80美元，仅GPU费用。
那是因为我有一台不错的PC来处理数据。如果我有更多的RAM，我就可以更快地处理一些数据，尤其是在内存中去重文本时。

**免责声明**：这是一个玩具/业余LLM（但我非常认真地对待它）。

它会产生幻觉，并生成历史上半准确的内容，这些内容在当时被认为是正常的，但根据今天的标准被认为是：有毒的、冒犯性的和不安全的。这是预料之中的，因为我没有进行任何对齐。对模型进行对齐（或审查）需要巨大的努力，而且这会破坏历史准确性。

此外，我不能保证我的模型严格限制在1900年（即使我尽了最大的努力），例如：在进行“阿尔伯特·爱因斯坦测试”时。

### 计划

我每天在工作中都使用AI，我了解它是如何运作的，但我自己从未构建过LLM。我在工作中运行过特定的AI训练和微调流程，过去我用C和Python构建过微小的神经网络，但在开始这个项目时，我不知道人们通常是如何构建LLM的。

我花了一周时间搜索，并与多个机器人聊天以获得不同的观点（就像我在研究某个主题时总是做的那样）。

简而言之，要构建一个LLM，你需要四样东西：

- **数据**-- LLM没有辨别力或理解力。它会从你告诉它的任何东西中学习，无论是好是坏。这是最漫长的过程。
- **分词**-- 分词器是一个将单词或字母转换为数字（标记/tokens）的小程序。LLM不理解单词，它们只理解数字。
- **预训练**-- 这是一个令人困惑的表达，它指的是“基础训练”，即LLM学习自动完成文本。如果你追求300m+参数，这是最昂贵的过程。
- **微调**-- LLM学习如何轮流聊天、问答。

嗯，它比这些简单的步骤要复杂一些，但我不会在这篇文章中深入探讨。

现在，让我们更详细地看看每一步。

### 初步实验

值得一提的是，我犯了很多错误，在确定“大”模型之前，我试验了许多数据集和模型架构。

（这里的“大”是引号中的，因为你知道，与Talkie-13B或TypewriterLM-7.24B等更大的模型相比，我的模型只是一个玩具）

关于我在自己的PC上训练的v2玩具EleutherAI/pythia-14m的一些细节：

https://github.com/croqaz/vintage-LLM/tree/e272b94fcf96316f874babbed549d20809fe5a39/models/m-v2

如果你查看验证损失和困惑度SVG文件，你会看到巨大的跳跃，因为我没有随机化文件块，数据集文件是按字母顺序分词的，而且碰巧干净的书籍文件是排在最前面的，一旦模型开始接触Time-Capsule数据集，它就逐渐变得越来越差，因为该数据集很糟糕，包含许多奇怪的OCR伪影、破碎的单词和句子等等。

犯了错误……但我从中吸取了教训。
我卡住了一段时间，直到我开始过滤掉那些不好的文档。

### 数据

数据处理是迄今为止最长、最无聊的过程，我希望你们能理解原因……

互联网上有很多现代、高质量的数据集，但我不希望我的 LLM 学习关于计算机、原子弹和宇宙飞船的内容，所以我别无选择，只能自己制作。

幸运的是有一些数据集可用，但它们的质量相当差，我大部分的工作是去去重、过滤掉非常糟糕的文本，并增强一些现有的文本。

历史数据集相当有限，除非我们发现更多旧书并有人扫描它们，否则旧书就是我们所拥有的全部，所以我们必须使用我们现有的。

值得一提的几个数据集有：Project Gutenberg, Oxford Text Archive, Internet Archive books, TheBritishLibrary/blbooks, storytracer/LoC-PD-Books, dell-research-harvard/AmericanStories, dell-research-harvard/NewsWire, Heritage Made Digital Newspapers (HMD)。

我尽力找出每个数据集的年份和语言，这样我就可以将所有内容限制在 1900 年之前的英语。

我完全忽略了没有指定年份的文档，或者我无法在文本中找到日期的文档，即使它们质量很好，也是为了安全起见。

作为一项副项目，我创建了包含大量旧书、标题、作者、书籍 ID 和来源的 Book-Metadata HF 数据集：https://huggingface.co/datasets/croqaz/book-metadata；我的目标是找出所有 Gutenberg 书籍的年份，但我只找到了 5300 本我能 100% 确定年份的。

再次强调，这花费了绝对漫长的时间，在我写这篇博客文章时，我还没有完全完成。

如果我将来训练另一个 LLM，下次我会拥有更多、更好的数据。

最初我想要几种去重方法，包括 MinHash 和嵌入向量相似度。如果你不知道这意味着什么，不用担心，我不会详细说明。它太慢、太昂贵了，我不得不放弃它。为了让你感受一下这有多慢，我让一个强大的 DEV 服务器为我的短文本数据集计算嵌入，在服务器日夜运行的情况下，我一周完成了数据集的 10%。该服务器有一个我共享的 RTX 3090 GPU，等等。

最后，我基于规范化文本进行了去重（去除所有空格的小写文本）。基本上，文本 "hello world" 与文本 " Hello World " 是相同的（注意空格和标题大小写），该文本只在我的数据集中保存一次。

从一开始，我就知道数据是最重要的：垃圾进 -> 垃圾出。我进行了大量的实验和迭代，我尝试了 Qdrant、Zvec、Lance、ValKey 和 LevelDB 等数据库来存储数据集。

我放弃了 Qdrant，因为在开始添加大量条目之前，数据库的磁盘大小就已经非常庞大了。
我放弃了 `Zvec`，因为我没有办法循环数据库条目，基本上一旦保存了它们，就无法探索数据库。我为此创建了一个问题。`Zvec` 也非常新，我可能应该给它更多时间成熟。

我放弃了 `Lance` 是因为版本控制问题，一旦开始添加超过几百万条目，数据库就会越来越慢。这可能是我的错，我确信我可以找到更好的方法来处理这个问题。

我放弃了 `ValKey` 是因为内存耗尽，在导入大约 1000 万条记录后，我的电脑上的服务器开始发生 OOM 崩溃，但我仍然需要导入更多数据。除此之外，`ValKey` 非常棒。

我最终使用了 `LevelDB`（它曾被本地钱包应用用于存储比特币和以太坊交易），所以我知道它可以在我的电脑上扩展。我导入了 1200 万行记录，没有任何问题，并且 CPU 或 RAM 使用量极小。`LevelDB` 有时可能会很慢，但它始终是可靠的。

如果我有更好的电脑，或者超级计算机，我可能一直使用 `ValKey`。

为了了解文本的质量，我首先查看了每个文档的长度和唯一字符数。在第一阶段，我决定使用短文本（长度不超过 32k）；在第二阶段，使用长文本，长度不超过 10MB。英语通常不应该使用超过 30-50 个符号；如果一个文本块有 100 个或更多的唯一符号，它就不是英语，所以我丢弃了这些。如果文本只有 8 个唯一符号，也没有意义，所以我也移除了这些。

我应用了另外 3 个过滤器。

一个非常简单的指标是 `ZLIB` 的压缩比。文本如果太短且多样化，其值会很大；而高度重复的文本其值会非常小。
```
# ZLIB compression ratio
# A good window is 0.5...0.7;
def compression_ratio(text) -> float:
    raw = text.encode("utf-8")
    compressed = zlib.compress(raw)
    return len(compressed) / len(raw)
compression_ratio("Lorem ipsum dolor sit amet")
# 1.3
compression_ratio("other, and other and other" * 100)
# 0.01 -- very repeated
compression_ratio("The President has nominated Thomas Johnson, William Cranch, and Charles\nSimms, Judges of the district of Columbia.\n\nOn Saturday last, Thomas Jefferson, at\npresent Vice President of the United States,\nand President of the Senate, took leave of\nthat body on which occasion he delivered\nthe following address:\n\nGentlemen of the Senate,\n\nTo give the usual opportunity")
# 0.64 -- Regular text
```
此外，香农熵：
```
# Shannon Entropy
# The estimated entropy rate for printed English is approximately 4.2...5.5;
def char_entropy(text) -> float:
    counts = Counter(text)
    total = len(text)
    entropy = 0.0
    for count in counts.values():
        p = count / total
        entropy -= p * log2(p)
    return entropy
char_entropy(("a " * 10 + "!"))
# 1.22 -- Too low
char_entropy("Lorem ipsum dolor sit amet")
# 3.6 -- A bit low
char_entropy("IN the High court of Chancery for the Rich\nmond District,\nBetween\nHenry Banks plaintiff,\nAnd\nNathaniel Anderson, Robert Pollard.")
# 4.5 -- Regular english
char_entropy(''.join(chr(i) for i in range(200)))
# 7.6 -- Super high entropy
```
还有我自己的质量检测过滤器。这帮助我识别了非常差的OCR文本，包含大量奇怪符号的：
```
_LETTER_RE = re.compile(r'[a-zα-ωàâäçèéêëîïôöùûüüÿæœß]$', re.I)
_DIGIT_SPACE_RE = re.compile(r'[0-9 \n]$')
_PUNCT_RE = re.compile(r'[.,;!?\'"_\-]$')
# Cro's custom quality score
# Regular letters get a score of 2;
# Digits and spaces get a score of 1;
# Punctuation gets 0.5;
# Any other characters get -0.5.
def quality_score(text: str) -> float:
    score = 0.0
    for c in text:
        if _LETTER_RE.match(c):
            score += 2
        elif _DIGIT_SPACE_RE.match(c):
            score += 1
        elif _PUNCT_RE.match(c):
            score += 0.5
        else:
            score -= 0.5
    return ((score / len(text)) - 0.75) * 100
quality_score("-.•-, , _ ._. , •\n1.\n- ,\n.... - • 4\n-------._\n..77/:',. .., ..., : •\n':'#)).,-'' 1 -\n__LI -......-_-.A..-...',... ) •\nSilli° , A AilitA4‘\n' •:.:-',73 ..-.-..-_-_,N>\n4. .41t.")
# -8.72
quality_score("Lorem ipsum dolor sit amet")
# 109.61
```
在计算了这些指标后，我简单地移除了低质量的文档。

被移除文档的百分比不到 1%。

所有这些实验都耗费了很长时间，限制因素始终是计算能力。还有一些我可以处理的数据集（例如：Institutional Books 1.0，巨大的 947GB 数据集，983K 本书，386M 页等），但我不想让我的电脑崩溃，而且我已经为我的小型 LLM 准备了足够的数据。

你可以在 HuggingFace 上找到我的数据集：https://huggingface.co/datasets/croqaz/vintage-v1 ;

### 分词

我不得不制作自己的分词器，因为我的模型永远不需要像 "async function"、"import sys"、"public class Main" 或任何其他编程语言术语这样的词汇表。

而且这是一个仅限英文的 LLM，所以我不希望它采纳其他语言的表达。

如果我使用了现有的分词器，所有那些无用的词汇都会被浪费在词汇表中。

我在英文古腾堡和牛津书籍上训练了我的分词器，因为它们非常干净。

### 基础训练阶段-1

一旦有了基础数据集，我使用 litGPT 框架快速创建了一个超级基础的 Pythia-14M 参数模型（即 0.01B 参数）。最初这过程相当直接且顺利。

我不得不做一些调整才能让它在我的 PC 上运行，因为我使用的是 Radeon GPU，而大多数 AI 训练脚本都默认你拥有 NVIDIA GPU……

仅用一个小时，我就拥有了一个生成半随机的、听起来像英文的胡言乱语的小型 LLM，例如：
```
He presented them with one of the soul, which was made in the same manner ;
I have also been at this moment's, and that it was not that this month should be allowed to
be without a short time. It was not yet a word for the sake of the man who was known that he
was in the case of the law that he was going herein, which was made to it, and be a thing
to be understood, that the word must be ...
It was a wild and strange desire, and has, on his head, and the only farm, or the black sky,
he was in the midst of the face of the night.
But his first illness was a great, and the heart he was a man who had his hands,
for he was a very much gotten, and he was very weak.
His mouth were, but was in his hand.
He was a man of great honour, and there was one of ...
```
玩了更多之后，我尝试训练一个更大的 Pythia-70M，结果 litGPT 开始随机崩溃，出现像这样的错误：
```
ERROR: Unexpected segmentation fault encountered in worker.
raise RuntimeError(
  f"DataLoader worker (pid(s) {pids_str}) exited unexpectedly"
) from e
```
我对 Pythia-14M 使用了完全相同的分词器和数据集，我尝试了 Pythia-31M 和 Pythia-160M，但 70M 却不行。我尝试了很长时间进行调试但没有成功，浪费了很多时间，最后我决定制作自己的训练脚本，这个脚本大致受到了 litGPT 和 nanoChat 的启发。

我发现 HuggingFace transformers 库有一个 Trainer 类，我进行了一些“感觉式编码”来创建一些基础的东西。

我下载了 nano-GPT、nano-Chat、NanoWhale-100m 以及其他一些代码“从零开始”的仓库的源代码，并让不同的 LLM 提取了它们进行基础训练的技术细节，然后我要求 LLM 将最好的功能应用到我自己的训练脚本上。通过这种方式，我在几次迭代中成功获得了一个相当扎实和灵活的东西。

我反复手动调整代码，直到它符合我的要求，并且我理解了它的工作原理。

我故意不想使用 nanoChat，因为我希望它能与 HuggingFace 库以及未来的 GGUF 保持 100% 的兼容性。

在我的个人电脑上训练了几个调试版本后，是时候扩大规模并在云端进行训练了。

我尝试了 200M 参数（上下文为 2048 个 token）和 340M 参数（上下文为 4096 个 token），两者都基于 Llama3 架构。

RunPod 还可以，功能齐全，但价格昂贵。我训练了 0.2B 参数的 LLM，但我没有上传它，因为它上下文太小，我决定放弃它，即使我花了一些钱……我真的想要一个 4k+ 的上下文大小。

我在 ThunderCompute 上开始训练 0.3B 参数的 Llama。它非常慢，GPU 的生产价格甚至比 RunPod 更高，这是一个很大的失望，但我投入了 $25 信用额度，我想花完它，所以我让训练运行以消耗所有信用额度。

Vast.ai 最初在其基础 Docker 镜像上存在各种问题，无法启动任何实例，但在尝试和重试后，我在捷克找到了一个使用 NVIDIA RTX PRO 5000 的好实例，并让它运行了 10,000 步（略少于 3B 个 token）。我肯定会再次尝试 Vast.ai，因为价格非常有竞争力，一旦你找到一个好的实例，它就非常快和稳定。

这个阶段花费了我 $25 + $15 在 ThunderCompute + Vast.ai 上。

该阶段的训练指标：

### 基础训练阶段-2

我使用了长文本，大小从约 20k 到 10MB。

在这个阶段我意识到，长文本在所有先前指标上得分都非常好：自定义质量、熵和压缩，但它们包含大块的糟糕的 OCR 伪影，例如：
```
--- Match #5/12310 (0fc6a6f36d5e1f02f9e5b000c480efe5005b6be5de6f819b9309b60b577fb242) ---
{
  "source": "LOC",
  "len": 385331,
  "uniqChar": 64,
  "tokens": 73087,
  "sentences": 4555,
  "entropy": 103.85,
  "quality": 95.95,
  "compress": 91.92,
  "text": "M; \n\n\n\n1 ? 70 \n\n\n\nary. \n\n\n\nwtodrawn. timm \n\nM COLLEGE LIBRARY \n\n\n\nMARK \n\n\n\nY \n\n\n\n\\ \n\n\n\nJ \n\n\n\nREV. JAMES DAVIE S \n\n\n\nCOFI ANT \n\n\n\nY DIWEDDAR \n\n\n\nB ARC II. JAMES DAYIES, \n\n\n\nGan Y PARCH. G. GRIFFITHS, \n\nCINCINNATI, 0. \n\n\n\nUTICA, N. Y. \n\nT. J. GRIFFITHS, ARGRAFFYDD, EXCHANGE BUILDINGS. \n1875. \n\n\n\nI \n\nw \n\n\n\nC YN W YS I AD. \n\n\n\nAt y Darllenydd 4 \n\nRhaglith 5 — 11 \n\ncofiant 12 — 4q \n\nEnglynion Coffadwriaethol 49 \n\nPregethau 50—96 \n\nAmlinelliad o'i Brif Weddnodau 97 — 106 \n\nAdgofion Personol am Dano 107 114 \n\nAdgofion Brodyr Eraill am Dano 114— 133 \n\nYsgubau o Loffion Difyrus am Dano i34_ I4 g \n\nPenillion Coffadwriaethol 149—156 \n\nEnglish Department 157 ^3 \n\nCawellaid o Fan Saethau ei Fwa 174—187 \n\nPynciau Ysgol < . 188—222 \n\n\n\nAT Y DARLLENYDD. \n\n\n\nEr ys llawer o flynyddoedd cyn ei farwolaeth ceisiasai y Parch. \nJames Davies gan ei hen gyfaill, Iorthryn Gwynedd, ysgrifenu ei \ngofiant, os goroesai ef. Addawodd yntau wneyd; a chydnabyddid yn \ngyffredinol ddoethineb y dewisiad. Ond o herwydd anghydwelediad \ncydrhyngddo a'r perthynasau, parthed i ddull ei ddygiad allan, efe a \nymwrthododd yn bendant a'r cyfrifoldeb. Teimlwn fod yn ddyled- \nswydd arnom ddweyd cymaint a hyna mewn cyflawnder a'r brawd \nThomas, er mwyn symud ymaith y dybiaeth mewn rhai manau, mai \nam na roddasid iddo fwy o arian at yr anturiaeth yr ymryddhaodd \noddiwrth ei ymrwymiad. Wedi iddo ef nacau, disgynodd y gwaith \narnom ni, trwy ddewisiad unol, a thaer ddymuniad y weddw a'i \nphlant. Yr oedd yn anhawdd genym gydsynio, o herwydd amledd a \nphwysigrwydd ein dyledswyddau i bobl ein gofal. Ond (i'w credyd \ncofnoder y ffaith), pan ddeallasant fod hyny yn peri i ni betruso, pas- \niasant yn unfrydol benderfyniad i ysgafnhau ein dyledswyddau idd- \nynt hwy tra yn parotoi y bywgraffiad, ac wedi y gorphenem, eu bod \nyn rhoddi i ni fis o orphwysiant.   ...   nnheilwng. Ymdrechwn fod yn gyfarwydd a nodau gwir \nGristion. Nac ymorphwyswn ar farn dda a ddwg dyn- \nion am danom. Gymerwn y gair yn rheol ; ymarferwn \nffydd ar aberth Iesu, a llefwn am oleuni a chymorth yr \nYsbryd Glan at y gorchwyl. Gochelwn gymeryd ein \ntymer na'n teimladau yn rheol i holi ein hunain ; ond \nBeibl Duw fyddo ein prif faen prawf. Dyma reol y \nfarn. \n\n\n\nY DIWEDD. \n\n\n\n"
}
--- Match #31/87899 (70fa969d373b988d5537a08ed47ccd6842c17bdcecb2cb55181e3cf37f3e13a1) ---
{
  "source": "LOC",
  "len": 330083,
  "uniqChar": 64,
  "tokens": 62805,
  "sentences": 5311,
  "entropy": 104.92,
  "quality": 94.84,
  "compress": 92.95,
  "text": "\nQass_„L X724 ( \nBook _ \n\n\n\nCOFIANT, \n\n\n\nPREGETHAU, A BARDDONIAETH \n\n\n\nY DIWEDDAE \n\n\n\nBARCH. T. PIERCE, LIVERPOOL; \n\n\n\nPAKCH. H. E. THOMAS, \n\nBIEKENHEAD. \n\n\n\nLIVEKPOOLr AEGEAEEWYD GAN THOMAS LLOYD, \n\nTITHEEAKN STEEET. \n\n\n\nIBXtxgq \n\n\n\nIn Exchange \nThe Nat. Libr'y of Wales \nAug. 1928 \n\n\n\nAT Y DARLLENYDD, \n\n\n\nAmcenAIS wneyd y Cofiant nior fyr a cbryno ag y galhvn, er mwyn \nxhoi y Pregetliau a'r Farddoniaetb i mewn. Diau y buasai yn dda \ngan lawer ei gael yn gynt, ond nid oedd modd i mi \"vraeyd, a \nebredwyf fod peth mantais Avedi ei gyraedd trwy yr oediad. Dylai \nesgeulustra Mr. Pieece yn cadw cofnodion o'i fywyd, fod yn \nrhybydd i'r rhai y byddai eu Cofiant o ddyddordeb ac addysg i'r \nbyd. Dymunaf gydnabod yn y modd mnvyaf diolcbgar y lliaws \nCyfeillion a roisant bob cymbortb i mi gasglu y defnyddiau, ac \nyr -wyf yn gadael ar y rbai oeddynt yn adnabod fy amvyl dad \ny'nghyfraith oreu i fainu am gywirdeb y Cofiant. Bu llawer, ac \nrnae cryn nifer eto o'i Bregethau goreu ar wasgar, y rbai pe eu \ncesglid gyda'r gweddill Barddoniaetb, a alien t -vraeyd Ail Gyfiol \nwertbfawr. \n\nGwelir oddiwrth restr y Tanysgrifwyr am hvyddiant yr antur- \naetb, ac y mae genyf addewid y gwertbir Uawer mewn ardaloedd \nna ddaetb dim emvau oddiyno. \n\nBydd yn rbwydd iawn i'r cyfarwydd ddiwygio yr ycbydig \nwallau argraffyddol sydd yn y Gyfrol. \n\nGan ddiolcb am bob cymbortb, a dymuno am bob llwydd a \n\nbenditb, \n\nY gorpbwysaf, &c, \n\nH. E. THOMAS, \n\n50, Exmoeth Street, Birkenhead, \n\nMehefin 28ain, 1804. \n\n\n\nCYNHWYSIAD. \n\n\n\nCOFIANT, \n\n\n\nTUDAL. \n\nPen. I. Prif helyntion ei \nFywyd Boreuol 5 \n\nPen. II. Ei Fywyd a'i lafur \nGweinidogaethol . . . . 17 V. Esgeuluso cyd- \ngynnulliad \n\nPeeg. VI. Anfeidrol rinwedd \naberth y Groes \n\n\n\n62 \n\n\n\ni)0 \n\n69 \n\n71 \n71 \n\n74 \n\n\n\nPeeg. VII. Galwad ar Sion i \nDdeffroi \n\nPeeg. VIII. Y gwr ar y march \ngwyn \n\nPeeg. IX. Gogoniant a di- \ngonolrwydd trefn gras yn \nngwyneb trueni dyn fel \npechadur \n\nPeeg. X. Yr henbobl.. .. \n\nPeeg. XI. Gogoniant ac ar- \ndderchawgrwydd eglwys Dduw \nyn y dyddiau diweddaf . . \n\nPeeg. XII. Cysylltiad bywyd \nduwiol a manv dedwydd . . \n\n\n\n78 \n\n\n\n79 \n\n\n\n97 \n\n\n\nBAEDDON1AETH. \n\n\n\nMawrnad Dewi Wyn o Eifion 101 \nHaman a Mordecai . . . . 121 \nGalareb am y diweddar Barch. \n\nJ. Breeze 137 \n\nMarwnadyParch.J. P.Davies 148 \n\nCywydd i'r Goleudy . . . . \n\nA WORLD LEADER IN PAPER PRESERVATION \n1 1 1 Thomson Park Drive \nCranberry Township, PA 16066 \n(724)779-2111 ' \n\n\n\n"
}
```
这些样本总体得分很高，但它们是没用的。我猜这不是英文文本……我统计了几个百个例子，大部分来自 LOC-PD，另外还有几个百个来自 OTA 数据集。想象一下，如果我把这些垃圾喂给我的 LLM，它会学到什么？

我搜索了一下，决定计算一些额外的指标，比如：字典词搜索、单词中的元音、噪声计数。通过这些值，在将所有值组合成一个单一分数后，我只保留了质量最好的文档。我确信它不是完美的，但在探索数据集时，我对看到的数据相当满意。

我计算出低质量文档占总数的不到 1%，这与短文本数据集是一致的。

顺便说一句，所有用于导入、查询和计数数据集条目的代码都是开源的：https://github.com/croqaz/vintage-LLM/tree/main/dataset ;

如果我有更多的计算能力，或者训练一个更大的 LLM，我还有海量数据可以使用，但我决定限制自己，因为这已经耗费了太长时间了。

我再次在 Vast.ai 上运行了这次训练，使用的是法国的 RTX PRO 6000 WS，共进行了 10,150 步（约 6B tokens）。

正如您在下面的指标中看到的，我进行了两轮训练。因为我启动了实例，但在上传模型检查点时，我的分词脚本因 OOM 而崩溃了。所以，在我修复它并再次运行它时，我快速地对一个子数据集进行了分词处理，这个子数据集包含旧诗歌、引语、谚语和牛津精选书籍，这些内容我无论如何都想使用（都在时间范围内），只是为了让 GPU 保持忙碌。第二轮只是上述随机的长文档。

这一阶段花费了我 40 美元。

这一阶段的指标：

根据 Chinchilla 缩放定律，3+6=9B tokens 大约是这个 340M 参数模型的正确训练令牌数量。

### 微调

在我撰写这篇博客时，这个阶段还没有完成，等准备好了我会发布另一篇帖子。

我创建了一系列 Python 脚本来生成一个“基础知识”数据集，以便我可以基于此对模型进行微调，使其理解对话。关于食物、水果、蔬菜、一些动物和鸟类、颜色、一些数字的基础问答。经过几次使用不同调整进行微调后，我让它输出了稳定的对话。我很高兴地看到，仅用几个百个例子，它就学会了 Question:... 后面跟着 Answer:... 的结构。

此时的一些样本，使用了最终模型 + 使用我的常识数据集进行了轻度微调。
```
User: What is God?
LLM #1: God is the absolute ruler, and in him only we have hope and strength.
LLM #2: A Being of a God-like character would be a being who knew himself to be the supreme Being, and by whom alone we can act.
LLM #3: The sun shines on the earth and the stars reflect the light.
User: What is love?
LLM #1: Love is a powerful impulse and it enables us to overcome our inclinations.
LLM #2: Love is the result of a certain condition of the human being in which love exists; as, love a man because he loves you.
LLM #3: Love is a desire to please and the object of an action is the gratification of some passion or affection for a particular person or thing.
User: What is life?
LLM #1: Life is a warfare against pain, and the longer we live the more we suffer.
LLM #2: Life is a great struggle for existence, in which each one has to sacrifice his own individual pleasure and to seek the best good of others.
LLM #3: Life is life, and its issues are to the soul what the heart is the heart.
# Trying a few greetings
User: How are you?
LLM #1: Heat, fire and cold are required of them in order to overcome their resistance.
LLM #2: We use our best books on astronomy.
LLM #2: The weather is charming.
User: Greetings, good sir!
LLM #1: The best of all is that when you have done.
LLM #2: Gladly! Thanks for the honor. I was thinking of writing one.
LLM #2: No; I hate their thoughts. They are not of my mind, but my memory.
# Asking for a few names
User: What's your name?
LLM #1: Charles Emile de Saint-Valerie.
LLM #2: Ninette. I belong to the ancient class.
LLM #3: Charles Rickards.
LLM #4: Charles Bamford, of the "Nineteenth Century".
LLM #5: My mother was a slave, my father a slave.
```
所有样本均使用我的 `"generate.py"` 脚本生成，参数为 `*temperature=1.0, top-p=0.9, top-k=25, min-p=0.01, repetition-penalty=1.1*`。

该模型幻觉很多，不太遵循对话。你暂时不能和它聊天，它还需要更多的打磨。

所有的对话就像一台赌博机：投入一枚硬币，拉动杠杆，然后祈祷最好的结果。你有时会得到一些不错的东西。

看到模型能如此出色地回答关于神、爱和生活的提问，真是个惊喜，尤其是这些内容不在我的“基础知识”数据集中，模型是从长时间的基础训练中吸收的，并在其上学会了应用聊天模板。

### 模型能记住数学吗？

在我的微调知识文件中，我随意添加了一些简单的数学运算，并没有多加思考，但在我用不同提示在训练阶段进行“感受测试”时，我实际上是问了“1 + 1 等于多少？”来观察情况，但答案通常是一个随机数，或者完全是胡言乱语。

所以我想知道：模型能否记住基础的数字数学运算，比如从 -2 到 12 的数字？

我生成了一个包含 5300 个数学问题的语料库，涵盖了所有基础运算（+ - / *），涉及所有从 -2 到 12 的数字，并使用了不同的提问方式，例如：

- “10 减 3 等于多少？”
- “7 乘以 10 等于多少？”
- “将 9 乘以 2。”
- “计算 -2 乘以 6。”

我制作了一个数学基准测试，要求模型对所有可能的运算和数字对（0 到 12）回答“计算 X 和 Y。”（我跳过了负数）。

与完整训练相比，微调速度非常快，所以我能够在几分钟内进行大量的实验并看到结果。

我从基础模型微调了几个模型，尝试了不同的超参数，我发现使用 LR=5e-5, max_seq_length=2048, neftune_noise_alpha=0.0（这对这种情况非常重要）以及显然 temperature=0 时获得了最好的结果。

最佳得分：
```
[ + ]  addition: 75/169 (44.4%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✗   ✗   ✓   ✗   ✗   ✓   ✗   ✗   ✗   ✗   ✓   ✗   ✓
  1 │   ✓   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗   ✓   ✓
  2 │   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✗
  3 │   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓
  4 │   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✓
  5 │   ✓   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✓
  6 │   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✗   ✓   ✓
  7 │   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓
  8 │   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✓   ✗
  9 │   ✗   ✗   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✗   ✓
 10 │   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✓   ✓   ✗   ✓
 11 │   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓
 12 │   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✗
[ - ]  subtraction: 114/169 (67.5%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  1 │   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓
  2 │   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓
  3 │   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✗
  4 │   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✗
  5 │   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✓
  6 │   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓
  7 │   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗
  8 │   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✗   ✓
  9 │   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✓
 10 │   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓
 11 │   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗   ✗
 12 │   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✗
[ * ]  multiplication: 118/169 (69.8%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓
  1 │   ✗   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  2 │   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  3 │   ✓   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✗
  4 │   ✓   ✓   ✓   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✓   ✓
  5 │   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  6 │   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  7 │   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  8 │   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✗
  9 │   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✗
 10 │   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗   ✓   ✗   ✗   ✓
 11 │   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓
 12 │   ✗   ✗   ✓   ✓   ✗   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✗
[ / ]  division: 85/156 (54.5%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ·   ✓   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  1 │   ·   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✗
  2 │   ·   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✗   ✓   ✓   ✓   ✓
  3 │   ·   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓
  4 │   ·   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗
  5 │   ·   ✓   ✗   ✗   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓
  6 │   ·   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✗   ✗
  7 │   ·   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✗
  8 │   ·   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✗   ✓   ✓   ✗   ✗
  9 │   ·   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✗   ✓
 10 │   ·   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✗
 11 │   ·   ✓   ✓   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓
 12 │   ·   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✗
  SUMMARY
  +  addition           75/169  ( 44.4%)  ████████
  -  subtraction       114/169  ( 67.5%)  █████████████
  *  multiplication    118/169  ( 69.8%)  █████████████
  /  division           85/156  ( 54.5%)  ██████████
  --------------------------------------------------
  TOTAL             392/663  ( 59.1%)
```
我惊讶于该模型在减法上的表现一直比加法好，因为减法的表述方式稍微复杂一些，例如：“从 3 中减去 2。”和“减去 3 - 2。”，数字的顺序是颠倒的。我本以为模型在加法上会表现最好（就像人类一样），但加法得分却是最差的……

无论如何，我没有能得到超过 60% 的分数，所以我认为这个模型无法记住基本的数学知识。

如果我错了请纠正我！留下评论告诉我我错过了什么！

显然，我不会把这个模型上传到 HuggingFace，只是为了让你下载一个 650MB 的大脑，它回答 1 + 1 的正确率只有一半……用计算器就行了，好吗？

### 训练过程中的状态观察

在不同步骤中测试模型，看看它会生成什么。

有趣的是，在训练开始时，模型正在学习单词的顺序，哪个词应该跟在哪个词后面。然后，它开始学习像句子这样更大的序列中的单词。接着，它学会了将 2-3 个句子连接起来。如果你继续训练它，它将学会如何构建一个长段落，但这需要一段时间……

### 第 200 步

模型仍然大部分是随机噪声。
```
--- Prompt 1 ---
User: Hello!
Model:
Hello!ltO,til,le
cansia
the tst. .
m'
o. the i6n
a 1
M. B. C. C. PI
.h.,
The
Fn.l
i.
n.
L
--- Prompt 2 ---
User: Who are you?
Model:
Who are you? a man
of the country, who was born for the
purpose of having been laid. We're to-day
the present occasion. The number of votes
was given up to the Bank from the South
Carolina in the county of War. In which they
had taken the whole. The proceedings were
allowed to produce from this great mass. This
were one of the most unnecessarily, and the
question ensued on the part of the company.
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend of her Ma t'estl. In all the other nations of his life and honour,
he would make a more than an instant, to any such thing as that has ever been done in the world.
It is impossible to expect that this country is in a condition in it...
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
the first and most important to which the State, and in its opinion, has been the great
and valuable to us. The Legislature of Russia was as follows :—" That the House of
Mr. H. M'Neard (Mr. S. H.) in Ireland was referred to an early period of money in
```
### 第 1000 步

模型学会了将一些词语连接起来。
```
--- Prompt 1 ---
User: Hello!
Model:
Hello! CIR. and HI, RAJUy
DESTROYED BUSINESS.
By Mr. j. r. FULLER, and Messrs. A. & J.
Mclean and J. E. Hubbard, MIR G. P. Roulton,
Mr. G. w. Harris of the firm Of E. +. Dexter,
and J. A. Brown OF the firm of
--- Prompt 2 ---
User: Who are you?
Model:
Who are you? — but God has a child, who wants to be the same, and he is a most excellent man. It has been an ornament of manners for a lady and an officer. I have always observed that the author does not write to me. — I am no stranger, my good friend ; but I shall look over his life with pleasure, if I do not be a stranger. As a stranger I believe, it will be my duty to speak to the young lady, the stranger, if not
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend, but in the course of an old acquaintance. — It is rather remarkable how much your lordship seems to be the manu facture of this most noble family, that you have so many a favouritewith me. — But this is not all I can conceive of; for it seems to me, that even this great object of that kind is to procure the benefit of our religious institutions to which I have referred. — The only difference be tween your own personal merit and his attachment. It is
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
He said there was no danger of such occurrence.
The plaintiff, the defendant, is a man of very respectable
character, and who has been in the service of the firm
of Messrs. Barrett and Co. for a period of three years, at
the rate of 50 per cent. on the gross value of his estate in
which he resided in the year 1830. He had for many
years previously kept an account of the business of the bank,
and it appeared
```
### 第 10,000 步 (stage-1 结束)

在这个阶段，我使用我的 CommonSense 数据集进行了非常轻微的微调，因此该模型生成了干净的文本。
```
--- Prompt 1 ---
User: Hello!
Model:
Hello! What a fine idea ! How many legs is this ? It is a sort of animal ; that's the beast. Oh, what is it? What is it? The horse has no tail. But it's a brute, and I am afraid I cannot find a tail in it. A horse has no tail, and he eats it, and eats it. And how is it? Oh, how much does it take to eat it? Oh, how much do they eat? And the horse is
--- Prompt 2 ---
User: Who are you?
Model:
Who are you?
Then, what is the difference between a man and his wife?
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend has been in the habit of walking about the streets for the last two or three days. He has walked to and fro in all directions in search of a place where he could purchase some articles at a cheap rate. This is not true, as you know; but it seems that you have been thinking about a place where you could buy a few articles at wholesale prices. This is a strange way of doing business, and you are often told that a man may make his goods cheap by buying them cheap
--- Prompt 4 ---
User: What's this place?
Model:
What's this place? Do you see it ? Do you see it ? I have seen it. Do you see it ? Is the tree that bears its fruit, and the fruit which is in the tree? Do you see it ? Are there trees that stand upon the ground? Is there any other trees of the same sort? Do you see them ? DO you see them ? Do you see them? Do you see them? Are they more common? Do you see them ? What are those ? Do you see them?
```
### 第 20,000 步 (阶段 2 结束)

在这个阶段，文本是半随机的，但它是连贯的。整段文本似乎来自同一本书，这非常好。

没有微调。
```
--- Prompt 1 ---
User: Hello!
Model:
Hello!” cried Mr. Dyer, “ the man is a
foolish fellow ; he must be made of some use.”
“ But I do not think so, sir,” said the lawyer, “ I
will tell you a story in one of my books. The case
of the old gentleman is this : — He had been living in
a strange country. His wife died, and his son took
charge of him. He did not
--- Prompt 2 ---
User: Who are you?
Model:
Who are you?”
The detective was standing by the table, with his
back toward the door.
“ You are going to get up that row?” he said.
‘‘Yes,” he replied.
“And go to get it done?”
“No.”
“Then we will see about it.”
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend, and I will give you the
advice of an honest man.
" The above is a literal translation : I do not doubt it ; but
I do not know whether the reader has read it himself.
" P. S. — I have just returned from the country. I am very
sorry to say I had rather be in the house myself than in any one's
house. If you please to remember me, sir, it shall be your
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
The devil himself is the devil !
THE VOICE OF THE HEART. 53
VOICE OF THE HEART.
I wish that I had never been born !
I'll never tell the tale of my sin !
I'll never tell it !
But, ah ! the words are full of pain ;
They sound as if they had grown more plain :
```
### 下一步

我还没有一个好的指令模型，我不会分享一个半成品，但我有很多正在处理的数据集：

- 我的常识数据集正在扩展，我已经准备了大约 7k 行数据，还有更多想法可以添加；
- 我有一份来自哲学家引言的列表，例如：亚里士多德、弗洛伊德、柏拉图等，我将把它们整理成问答对；
- 我从几本 1900 年以前的书籍中提取了干净的问题和答案，例如：
- 《新常识学校问题书 1888》
- 《高级问题书 1883》
- 《完整的同义词和反义词词典 1835》等；
- 我还没有处理完所有这些，但我会把它们作为一个单独的数据集发布。

- 我有一些旧词典，我计划从中提取词汇定义，并将其转换为更多的问答对；
- 我想从《国王詹姆斯圣经》中提取不同的主题，以创建更多的问答对；
- 我还有 `Talkie-13B-Q8-GGUF` 和 `Monad-GPT-Q8-GGUF`！我确信我可以生成一些合成数据集。

这些数据集，或者至少其中的一部分，应该有助于模型理解对话结构。我会进行实验。

一旦我拥有一个足够好的模型可以分享，我就会发布另一篇帖子。

### 结束

当我开始这个项目时，我故意没有定义“成功”。我没有从一个明确的目标开始。这首先是一个学习项目。

我只是希望从中得到某种可用的维多利亚时代对话。

但当我投入了如此多的时间和精力后，我惊讶地发现，在没有进行任何微调的情况下，它竟然如此糟糕……因此，我想动用我所有的创造力来创造一些足够体面的东西来分享。

你觉得呢？

你对这类工作感兴趣吗？

你会将这种 LLM 用于什么？

在这个“复古 LLM”的背景下，你希望我尝试什么？

如果你想联系我，你有几种方式：

- 在这里发表评论；
- 在 HF 讨论区发表评论：https://huggingface.co/croqaz/vintage-LLM-340m-v1-base/discussions；
- 在 Vintage-LLM 仓库中提交问题：https://github.com/croqaz/vintage-LLM/issues；
- 加入我们的 Vintage-LLM Discord 服务器并发送消息。

如果你想私下联系我，我的电子邮件是 *my short name* at *this domain*。**如果你是云 GPU 提供商，手头有一些积灰的 GPU，并想赞助我下一个模型的训练，请联系我**！我将使用所有计算资源来训练一个更大的 1B 模型，并使用更好的数据集；或者我可以将这个 340M 模型基础训练到 50,000 步，我有大量数据，任你选择！

如果你想阅读更多关于这类 LLM 的信息，请查看我的上一篇帖子：Vintage LLM models, lots of links。

我鼓励任何对人工智能和 LLM 感兴趣或感到兴奋的人做我所做的事情，并在训练阶段之间进行尝试，以便窥见幕后。你会很快忘记 AGI，但我保证这会很有趣！
也许在你的流程中找到一个转折点，一些别人没有做过的，也许是独特的数据集，或独特的训练方法，或LLM架构？但你没有必要这样做，无论如何你都会学到新东西的。我知道我学到了！

注：这篇博客文章百分之百由我撰写。没有使用任何AI。

---

## 原文

# Making a vintage LLM from scratch

In this blog post, I will share the adventures I had creating my own LLM, from (almost) scratch, trained only on old texts.

I made my own base-training and fine-tuning scripts, data processing pipelines and custom datasets.

("almost from scratch" means I did use existing programming languages and libraries, I didn't write in Assembly, just like anyone else who builds an AI "from scratch"...)

The model can be found on HuggingFace: https://huggingface.co/croqaz/vintage-LLM-340m-v1-base ;

All the code is open source at: https://github.com/croqaz/vintage-LLM ;

If you want to check bigger Vintage models, see my previous post: Vintage LLM models.

### The idea

Three months ago at the end of February I discovered a few Reddit posts by Hayk Grigorian, where he described creating his temporal gated language model. I was absolutely fascinated.

Training an LLM only on 1800s London texts, 90GB dataset:

https://reddit.com/r/LocalLLaMA/comments/1pkpsee/training_an_llm_only_on_1800s_london_texts_90gb

LLM trained from scratch on only 1800s London texts brings up a real protest from 1834:

https://reddit.com/r/LocalLLaMA/comments/1mvnmjo/my_llm_trained_from_scratch_on_only_1800s_london

Obviously I read other posts from other people that made their own LLMs, but maybe I wasn't ready to do it myself, or the model they were working on wasn't that interesting. Anyway, the thought of having my own Victorian chat bot... fuckin' epic !!

Since then, I worked on my own "Vintage LLM" every single day. Without exceptions. Even when I was sick.

In the meantime, a lot more historic LLMs have been released like: Violet-1B4-Chat, Mr. Chatterbox, GPT-1900, Talkie and TypewriterLM-base.

### What, why, where and how?

**What?**

This is a time-locked LLM/ historical LLM, English only, and its knowledge cutoff is year 1900.

(Limiting to a specific year is error prone, but I did my best effort).

It is based on Llama architecture and has 340M (0.3B) params.

**Why?**

Because I can only learn if I do it myself and it's a super fun project.

**Where and how?**

I made my own dataset, my own processing and training code.

The code is semi-vibe-coded with whatever LLM I had with VS-Code and PI (OpenRouter models).

I checked and validated every single function and I deeply understand what every single code file is doing.

The dataset processing took the most and I tried all sorts of things that didn't work, and I wasted a ton of time. Complicated solutions are the worst...

I processed all the data on my own PC and I trained smaller versions of the LLM on my PC (*Cachy OS Linux, AMD Ryzen 7 9700X CPU, 64GB RAM, Radeon RX 9070 16GB VRAM*).

As for the larger 340M model, I trained it on RunPod, ThunderCompute and Vast.ai. It would have taken forever on my PC.

The total cost of this project was: ~$80, GPU costs only.

That's because I have a decent PC to process the data. If I had more RAM, I could have processed some of the data much faster, especially when it comes to de-duplicating texts in memory.

**Disclaimer**: This is a toy/ hobby LLM (but I treat it very seriously).

It will hallucinate and generate historic semi-accurate content which, at the time was considered normal but by today's standards is considered: toxic, offensive and unsafe. This is expected, because I didn't do any alignment. Aligning (or censoring) the model requires significant effort and it would ruin the historic accuracy.

Also, I can't guarantee that my model is strictly limited to the year 1900 (even if I did my best) eg: as to perform the "Albert Einstein test".

### The plan

I use AI everyday at work and I understand how it works, but I never built an LLM myself. I ran specific AI training and fine-tuning pipelines at work, I built tiny neural networks in C and Python in the past, but when I started this project I didn't know how people are usually building LLMs.

I searched for a week and I chatted with multiple bots to get different points of view (like I always do when I research a topic).

In short, to build an LLM you need 4 things:

- **the data**-- an LLM has no discernment or understanding. It will learn from anything you tell it to, good or bad. This is the longest process.
- **tokenization**-- the Tokenizer is a little program that converts words or letters into numbers (tokens). LLMs don't understand words, they only understand numbers.
- **pre-training**-- it's a confusing expression and it means "base-training", where the LLM learns to autocomplete text. If you're going for a 300m+ params, this is the most expensive process.
- **fine-tuning**-- where the LLM learns how to chat in turns, question & answer.

Well, there's a bit more to it than these simple steps, but I won't go super deep in this article.

Now, let's look at each step in more detail.

### Initial experiments

It's worth mentioning that I made lots of mistakes and I experimented with some datasets and model architectures before I settled on the "big" model.

("big" in quotes here, because you know, compared to larger models like Talkie-13B or TypewriterLM-7.24B, my model is just a toy)

Some details about my v2 toy EleutherAI/pythia-14m that I trained on my own PC:

https://github.com/croqaz/vintage-LLM/tree/e272b94fcf96316f874babbed549d20809fe5a39/models/m-v2

If you look at the validation loss and perplexity SVG files, you'll see huge jumps, because I didn't randomize the file chunks and the dataset files were tokenized in alphabetic order, and it happened that the clean book files were first and as soon as the model started to get exposed to the Time-Capsule dataset, it gradually become worse and worse because that dataset was bad with lots of weird OCR artefacts, broken words & sentences and so on.

Mistakes were made ... but I learned from them.

I was stuck for a while, until I started to filter out the bad documents.

### Data

The data processing was the longest and most boring process by far, and I hope you understand why...

There are plenty of modern, high quality datasets with data scraped from the internet, but I didn't want my LLM to learn about computers, atomic bombs and space-ships, so I had no choice but to make my own.

Luckily there are some datasets available, but they are pretty bad quality and most of my work was to de-duplicate, filter the really bad texts and enhance some of the existing texts.

The historic datasets are quite limited, the old books are all we have unless we discover more old books and someone scans them, so we have to use what we have.

A few datasets worth mentioning are: Project Gutenberg, Oxford Text Archive, Internet Archive books, TheBritishLibrary/blbooks, storytracer/LoC-PD-Books, dell-research-harvard/AmericanStories, dell-research-harvard/NewsWire, Heritage Made Digital Newspapers (HMD).

I did my best to find out the year and language of each dataset, so I can limit everything to English before year 1900.

I completely ignored documents that don't specify a year, or I can't find date in the texts, even if they had good quality, just to be safe.

As a side-project, I created the Book-Metadata HF dataset with lots of old books, title, author, book ID and source: https://huggingface.co/datasets/croqaz/book-metadata ; My goal was find out the year of all Gutenberg books, but I only found 5300 books where I'm 100% sure of the year.

Again, this took absolutely forever and as I am writing this blog post, I'm still not completely finished.

If I'll ever train another LLM, I'll have more and better data next time.

Initially I wanted several de-duplication methods, including MinHash and embeddings vector similarity. If you don't know what it means, don't worry, I won't go into details. It was way too slow and expensive and I had to abandon it. Just to give you a taste of how slow this was, I had a beefy DEV server calculate embeddings for my short text datasets and I did 10% of the dataset in a week with the server running day & night. The server had a RTX 3090 GPU that I shared and so on.

In the end, I de-duplicated based on the normalized text (lower-case text with all spacing removed). Basically the text "hello world" is identical to the text " Hello World " (notice the spaces and title case), and the text is only saved once in my dataset.

From the start, I knew that the data is the most important: garbage in -> garbage out. I did lots and lots of experiments and iterations, I played with DBs like Qdrant, Zvec, Lance, ValKey, and LevelDB for storing the datasets.

I dropped Qdrant because the DB disk size was huge even before I started adding many entries.

I dropped Zvec because I had no way to cycle the DB entries, basically once you save them, there's no way to explore the DB. I created an issue for this. Zvec is also super new and I should probably give it more time to mature.

I dropped Lance because of the versioning, the DB becomes slower and slower once you start adding more than a few million entries. This could be my fault, I'm sure I can find out a way to do this better.

I dropped ValKey because I ran out of memory, after injesting something like 10 mil records, the server started to OOM crash on my PC, but I still had to injest way more data. Other than that, ValKey was really great.

I ended up using LevelDB (which was used by local wallet apps to store BitCoin and Ethereum transactions), so I know it can scale on my PC. I injested 12 mil rows without any issues and with minimal CPU or RAM usage. LevelDB can be slow at times, but it's consistently reliable.

If I had a better PC, or a super computer, I would probably have used ValKey all the way.

To get a sense of the quality of the texts, I was first looking at the length and unique characters of each document. For the first stage I decided to use short texts (up to 32k long) and for the second, long texts up to 10MB. English shouldn't use more than 30-50 symbols normally; if a chunk of text has 100 or more unique symbols, it's not English, so I discarded those. And if a text has only 8 unique symbols, it doesn't make any sense, so I removed those too.

I applied 3 more filters.

Super easy metric, the compression ratio of ZLIB. Text that is too short and diverse will have a big value and text that is super repeated will be really small value.

```
# ZLIB compression ratio
# A good window is 0.5...0.7;
def compression_ratio(text) -> float:
    raw = text.encode("utf-8")
    compressed = zlib.compress(raw)
    return len(compressed) / len(raw)
compression_ratio("Lorem ipsum dolor sit amet")
# 1.3
compression_ratio("other, and other and other" * 100)
# 0.01 -- very repeated
compression_ratio("The President has nominated Thomas Johnson, William Cranch, and Charles\nSimms, Judges of the district of Columbia.\n\nOn Saturday last, Thomas Jefferson, at\npresent Vice President of the United States,\nand President of the Senate, took leave of\nthat body on which occasion he delivered\nthe following address:\n\nGentlemen of the Senate,\n\nTo give the usual opportunity")
# 0.64 -- Regular text
```
Also the Shannon entropy:

```
# Shannon Entropy
# The estimated entropy rate for printed English is approximately 4.2...5.5;
def char_entropy(text) -> float:
    counts = Counter(text)
    total = len(text)
    entropy = 0.0
    for count in counts.values():
        p = count / total
        entropy -= p * log2(p)
    return entropy
char_entropy(("a " * 10 + "!"))
# 1.22 -- Too low
char_entropy("Lorem ipsum dolor sit amet")
# 3.6 -- A bit low
char_entropy("IN the High court of Chancery for the Rich\nmond District,\nBetween\nHenry Banks plaintiff,\nAnd\nNathaniel Anderson, Robert Pollard.")
# 4.5 -- Regular english
char_entropy(''.join(chr(i) for i in range(200)))
# 7.6 -- Super high entropy
```
And my own quality detection filter. This helped me identify very bad OCR texts, with lots of weird symbols:

```
_LETTER_RE = re.compile(r'[a-zα-ωàâäçèéêëîïôöùûüüÿæœß]$', re.I)
_DIGIT_SPACE_RE = re.compile(r'[0-9 \n]$')
_PUNCT_RE = re.compile(r'[.,;!?\'"_\-]$')
# Cro's custom quality score
# Regular letters get a score of 2;
# Digits and spaces get a score of 1;
# Punctuation gets 0.5;
# Any other characters get -0.5.
def quality_score(text: str) -> float:
    score = 0.0
    for c in text:
        if _LETTER_RE.match(c):
            score += 2
        elif _DIGIT_SPACE_RE.match(c):
            score += 1
        elif _PUNCT_RE.match(c):
            score += 0.5
        else:
            score -= 0.5
    return ((score / len(text)) - 0.75) * 100
quality_score("-.•-, , _ ._. , •\n1.\n- ,\n.... - • 4\n-------._\n..77/:',. .., ..., : •\n':'#)).,-'' 1 -\n__LI -......-_-.A..-...',... ) •\nSilli° , A AilitA4‘\n' •:.:-',73 ..-.-..-_-_,N>\n4. .41t.")
# -8.72
quality_score("Lorem ipsum dolor sit amet")
# 109.61
```
I after calculating these metrics, I simply removed the documents with low quality.

The percent of removed documents was less than 1%.

All of these experiments took forever, and the limiting factor was always the compute. There's a few more datasets that I could process (eg: Institutional Books 1.0, massive 947GB dataset, 983K books, 386M pages, etc) but I don't want to kill my PC, and I already have plenty of data for my tiny LLM.

You can find my dataset on HuggingFace: https://huggingface.co/datasets/croqaz/vintage-v1 ;

### Tokenization

I had to make my own tokenizer, because my model will never need a vocabulary like "async function", "import sys", "public class Main", or any other programming language terms.

And this is an English only LLM, so I don't want it to pickup expressions from other languages.

If I had used an existing tokenizer, all of those useless words would have been wasted in the vocabulary.

I trained my tokenizer on English Gutenberg and Oxford books, because they are very clean.

### Base-training stage-1

Once I had a basic dataset, I quickly created a super basic Pythia-14M params model (that's 0.01B params), using litGPT framework. It was pretty straightforward and painless initially.

I had to do some tricks to make it work on my PC, because I have a Radeon GPU and most of the AI training scripts just assume you have an NVIDIA GPU...

In just one hour, I had a tiny LLM that was generating semi-random English-sounding gibberish, eg:

```
He presented them with one of the soul, which was made in the same manner ;
I have also been at this moment's, and that it was not that this month should be allowed to
be without a short time. It was not yet a word for the sake of the man who was known that he
was in the case of the law that he was going herein, which was made to it, and be a thing
to be understood, that the word must be ...
It was a wild and strange desire, and has, on his head, and the only farm, or the black sky,
he was in the midst of the face of the night.
But his first illness was a great, and the heart he was a man who had his hands,
for he was a very much gotten, and he was very weak.
His mouth were, but was in his hand.
He was a man of great honour, and there was one of ...
```
After playing with it a bit more, I tried to train a bigger Pythia-70M and litGPT started to crash randomly with errors like:

```
ERROR: Unexpected segmentation fault encountered in worker.
raise RuntimeError(
  f"DataLoader worker (pid(s) {pids_str}) exited unexpectedly"
) from e
```
I had the exact same tokenizer and dataset for Pythia-14M and I tried a Pythia-31M and Pythia-160M, but the 70M just didn't work. I tried debugging this for a while without success, I wasted a lot of time and in the end I decided to make my own training script, loosely inspired from litGPT and nanoChat.

I discoverd that HuggingFace transformers library has a Trainer class and I did some vibe-coding to create something basic.

I downloaded the source code for nano-GPT, nano-Chat, NanoWhale-100m, and a few more repos with code "from scratch", and I got different LLMs to extract the technical details of how they do the base-training, then I asked the LLMs to apply the best features on my own training script. This way I managed to get something pretty solid and flexible in a few iterations.

I tweaked the code over and over again by hand, until I got it to my liking, and I understood what it was doing.

I intentionally didn't want to use nanoChat, because I wanted 100% compatibility with the HuggingFace libraries and with GGUF in the future.

After training a few debug versions on my own PC, it was time to go bigger and train in the cloud.

I tried a 200M params (w 2048 tokens context) and a 340M params (w 4096 tokens context), both based on the Llama3 architecture.

RunPod was OK and featureful, but pricey. I trained the 0.2B params LLM, but I didn't upload that anywhere, because it had a very small context, and I decided to discard it, even if I spent some money... I really wanted a 4k+ context size.

I started training the 0.3B params Llama on ThunderCompute. It was very slow and the production price of the GPUs was even higher than RunPod, I big disapointment, but I put $25 credit and I wanted to spend all of it so I let the training run to consume all the credits.

Vast.ai had all sorts of issues at first with their base Docker image, not being able to start any instances, but after some trying and re-trying, I found a good instance in Czechia with an NVIDIA RTX PRO 5000 and I let it run for 10,000 steps (a bit less than 3B tokens). I will definitely try Vast.ai again, because the price is very competitive and once you find a good instance, it's very fast and stable.

This stage cost me $25 + $15 on ThunderCompute + Vast.ai.

Training metrics for this stage:

### Base-training stage-2

I used the long texts, from ~20k up to 10MB in size.

In this stage I realized that the long texts have very good scores for all previous metrics: custom quality, entropy and compression, but they contain large chunks of bad OCR artefacts, eg:

```
--- Match #5/12310 (0fc6a6f36d5e1f02f9e5b000c480efe5005b6be5de6f819b9309b60b577fb242) ---
{
  "source": "LOC",
  "len": 385331,
  "uniqChar": 64,
  "tokens": 73087,
  "sentences": 4555,
  "entropy": 103.85,
  "quality": 95.95,
  "compress": 91.92,
  "text": "M; \n\n\n\n1 ? 70 \n\n\n\nary. \n\n\n\nwtodrawn. timm \n\nM COLLEGE LIBRARY \n\n\n\nMARK \n\n\n\nY \n\n\n\n\\ \n\n\n\nJ \n\n\n\nREV. JAMES DAVIE S \n\n\n\nCOFI ANT \n\n\n\nY DIWEDDAR \n\n\n\nB ARC II. JAMES DAYIES, \n\n\n\nGan Y PARCH. G. GRIFFITHS, \n\nCINCINNATI, 0. \n\n\n\nUTICA, N. Y. \n\nT. J. GRIFFITHS, ARGRAFFYDD, EXCHANGE BUILDINGS. \n1875. \n\n\n\nI \n\nw \n\n\n\nC YN W YS I AD. \n\n\n\nAt y Darllenydd 4 \n\nRhaglith 5 — 11 \n\ncofiant 12 — 4q \n\nEnglynion Coffadwriaethol 49 \n\nPregethau 50—96 \n\nAmlinelliad o'i Brif Weddnodau 97 — 106 \n\nAdgofion Personol am Dano 107 114 \n\nAdgofion Brodyr Eraill am Dano 114— 133 \n\nYsgubau o Loffion Difyrus am Dano i34_ I4 g \n\nPenillion Coffadwriaethol 149—156 \n\nEnglish Department 157 ^3 \n\nCawellaid o Fan Saethau ei Fwa 174—187 \n\nPynciau Ysgol < . 188—222 \n\n\n\nAT Y DARLLENYDD. \n\n\n\nEr ys llawer o flynyddoedd cyn ei farwolaeth ceisiasai y Parch. \nJames Davies gan ei hen gyfaill, Iorthryn Gwynedd, ysgrifenu ei \ngofiant, os goroesai ef. Addawodd yntau wneyd; a chydnabyddid yn \ngyffredinol ddoethineb y dewisiad. Ond o herwydd anghydwelediad \ncydrhyngddo a'r perthynasau, parthed i ddull ei ddygiad allan, efe a \nymwrthododd yn bendant a'r cyfrifoldeb. Teimlwn fod yn ddyled- \nswydd arnom ddweyd cymaint a hyna mewn cyflawnder a'r brawd \nThomas, er mwyn symud ymaith y dybiaeth mewn rhai manau, mai \nam na roddasid iddo fwy o arian at yr anturiaeth yr ymryddhaodd \noddiwrth ei ymrwymiad. Wedi iddo ef nacau, disgynodd y gwaith \narnom ni, trwy ddewisiad unol, a thaer ddymuniad y weddw a'i \nphlant. Yr oedd yn anhawdd genym gydsynio, o herwydd amledd a \nphwysigrwydd ein dyledswyddau i bobl ein gofal. Ond (i'w credyd \ncofnoder y ffaith), pan ddeallasant fod hyny yn peri i ni betruso, pas- \niasant yn unfrydol benderfyniad i ysgafnhau ein dyledswyddau idd- \nynt hwy tra yn parotoi y bywgraffiad, ac wedi y gorphenem, eu bod \nyn rhoddi i ni fis o orphwysiant.   ...   nnheilwng. Ymdrechwn fod yn gyfarwydd a nodau gwir \nGristion. Nac ymorphwyswn ar farn dda a ddwg dyn- \nion am danom. Gymerwn y gair yn rheol ; ymarferwn \nffydd ar aberth Iesu, a llefwn am oleuni a chymorth yr \nYsbryd Glan at y gorchwyl. Gochelwn gymeryd ein \ntymer na'n teimladau yn rheol i holi ein hunain ; ond \nBeibl Duw fyddo ein prif faen prawf. Dyma reol y \nfarn. \n\n\n\nY DIWEDD. \n\n\n\n"
}
--- Match #31/87899 (70fa969d373b988d5537a08ed47ccd6842c17bdcecb2cb55181e3cf37f3e13a1) ---
{
  "source": "LOC",
  "len": 330083,
  "uniqChar": 64,
  "tokens": 62805,
  "sentences": 5311,
  "entropy": 104.92,
  "quality": 94.84,
  "compress": 92.95,
  "text": "\nQass_„L X724 ( \nBook _ \n\n\n\nCOFIANT, \n\n\n\nPREGETHAU, A BARDDONIAETH \n\n\n\nY DIWEDDAE \n\n\n\nBARCH. T. PIERCE, LIVERPOOL; \n\n\n\nPAKCH. H. E. THOMAS, \n\nBIEKENHEAD. \n\n\n\nLIVEKPOOLr AEGEAEEWYD GAN THOMAS LLOYD, \n\nTITHEEAKN STEEET. \n\n\n\nIBXtxgq \n\n\n\nIn Exchange \nThe Nat. Libr'y of Wales \nAug. 1928 \n\n\n\nAT Y DARLLENYDD, \n\n\n\nAmcenAIS wneyd y Cofiant nior fyr a cbryno ag y galhvn, er mwyn \nxhoi y Pregetliau a'r Farddoniaetb i mewn. Diau y buasai yn dda \ngan lawer ei gael yn gynt, ond nid oedd modd i mi \"vraeyd, a \nebredwyf fod peth mantais Avedi ei gyraedd trwy yr oediad. Dylai \nesgeulustra Mr. Pieece yn cadw cofnodion o'i fywyd, fod yn \nrhybydd i'r rhai y byddai eu Cofiant o ddyddordeb ac addysg i'r \nbyd. Dymunaf gydnabod yn y modd mnvyaf diolcbgar y lliaws \nCyfeillion a roisant bob cymbortb i mi gasglu y defnyddiau, ac \nyr -wyf yn gadael ar y rbai oeddynt yn adnabod fy amvyl dad \ny'nghyfraith oreu i fainu am gywirdeb y Cofiant. Bu llawer, ac \nrnae cryn nifer eto o'i Bregethau goreu ar wasgar, y rbai pe eu \ncesglid gyda'r gweddill Barddoniaetb, a alien t -vraeyd Ail Gyfiol \nwertbfawr. \n\nGwelir oddiwrth restr y Tanysgrifwyr am hvyddiant yr antur- \naetb, ac y mae genyf addewid y gwertbir Uawer mewn ardaloedd \nna ddaetb dim emvau oddiyno. \n\nBydd yn rbwydd iawn i'r cyfarwydd ddiwygio yr ycbydig \nwallau argraffyddol sydd yn y Gyfrol. \n\nGan ddiolcb am bob cymbortb, a dymuno am bob llwydd a \n\nbenditb, \n\nY gorpbwysaf, &c, \n\nH. E. THOMAS, \n\n50, Exmoeth Street, Birkenhead, \n\nMehefin 28ain, 1804. \n\n\n\nCYNHWYSIAD. \n\n\n\nCOFIANT, \n\n\n\nTUDAL. \n\nPen. I. Prif helyntion ei \nFywyd Boreuol 5 \n\nPen. II. Ei Fywyd a'i lafur \nGweinidogaethol . . . . 17 V. Esgeuluso cyd- \ngynnulliad \n\nPeeg. VI. Anfeidrol rinwedd \naberth y Groes \n\n\n\n62 \n\n\n\ni)0 \n\n69 \n\n71 \n71 \n\n74 \n\n\n\nPeeg. VII. Galwad ar Sion i \nDdeffroi \n\nPeeg. VIII. Y gwr ar y march \ngwyn \n\nPeeg. IX. Gogoniant a di- \ngonolrwydd trefn gras yn \nngwyneb trueni dyn fel \npechadur \n\nPeeg. X. Yr henbobl.. .. \n\nPeeg. XI. Gogoniant ac ar- \ndderchawgrwydd eglwys Dduw \nyn y dyddiau diweddaf . . \n\nPeeg. XII. Cysylltiad bywyd \nduwiol a manv dedwydd . . \n\n\n\n78 \n\n\n\n79 \n\n\n\n97 \n\n\n\nBAEDDON1AETH. \n\n\n\nMawrnad Dewi Wyn o Eifion 101 \nHaman a Mordecai . . . . 121 \nGalareb am y diweddar Barch. \n\nJ. Breeze 137 \n\nMarwnadyParch.J. P.Davies 148 \n\nCywydd i'r Goleudy . . . . \n\nA WORLD LEADER IN PAPER PRESERVATION \n1 1 1 Thomson Park Drive \nCranberry Township, PA 16066 \n(724)779-2111 ' \n\n\n\n"
}
```
These samples have very good scores overall, but they are useless. I am guessing it's not English text... I counted a few hundred examples mostly from LOC-PD and other few hundred in the OTA datasets. Imagine if I feed that crap to my LLM, what will it learn?

I searched around and I decided to calculate a few more metrics like: dictionary word search, vowels in words, noise count. With these news values, I was able to keep only the best quality documents, after I combined all the values together in a single score. I'm sure it's not perfect, but when I explore the dataset I'm pretty happy with the data I'm seeing.

I calculated that the low quality documents were less than 1% of total, which was consistent with the short texts dataset.

By the way, all of this code to import, query and count the dataset entries is open source: https://github.com/croqaz/vintage-LLM/tree/main/dataset ;

I have a ton more data that I could use if I had more compute, or if I trained a larger LLM, but I decided to limit myself because this was taking forever already.

I ran this training on Vast.ai again, on a RTX PRO 6000 WS in France, for 10,150 steps (~6B tokens).

I did 2 rounds of training as you can see in the metrics below, because I started the instance and my tokenization script crashed due to OOM just when I was uploading the model checkpoints, so while I fixed it and ran it again, I quickly tokenized a sub-dataset of old poems, quotes, proverbs and Oxford clean books that I wanted to use anyway (all within the time period) just to keep the GPU busy. The second round was just the randomized long documents mentioned above.

This stage cost me $40.

Metrics for this stage:

Acording to the Chinchilla Scaling Law, 3+6=9B tokens is roughly the correct amount of training tokens for this 340M params model.

### Fine-tuning

This stage is not finished as I'm writing this blog, and I'll make another post when it's ready.

I created a series of Python scripts to generate a "base knowledge" dataset so I can fine-tune the model on, to make it understand dialogs. Basic question/ answers about foods, fruits, vegetables, some animals and birds, colors, a few numbers. After fine-tuning it a few times with different tweaks, I got it to spit stable dialogs. I was happy to see that it's learning the structure of Question:... followed by Answer:... with just a few hundred examples.

A few samples at this point, with the final model + a light fine-tuning with my CommonSense dataset.

```
User: What is God?
LLM #1: God is the absolute ruler, and in him only we have hope and strength.
LLM #2: A Being of a God-like character would be a being who knew himself to be the supreme Being, and by whom alone we can act.
LLM #3: The sun shines on the earth and the stars reflect the light.
User: What is love?
LLM #1: Love is a powerful impulse and it enables us to overcome our inclinations.
LLM #2: Love is the result of a certain condition of the human being in which love exists; as, love a man because he loves you.
LLM #3: Love is a desire to please and the object of an action is the gratification of some passion or affection for a particular person or thing.
User: What is life?
LLM #1: Life is a warfare against pain, and the longer we live the more we suffer.
LLM #2: Life is a great struggle for existence, in which each one has to sacrifice his own individual pleasure and to seek the best good of others.
LLM #3: Life is life, and its issues are to the soul what the heart is the heart.
# Trying a few greetings
User: How are you?
LLM #1: Heat, fire and cold are required of them in order to overcome their resistance.
LLM #2: We use our best books on astronomy.
LLM #2: The weather is charming.
User: Greetings, good sir!
LLM #1: The best of all is that when you have done.
LLM #2: Gladly! Thanks for the honor. I was thinking of writing one.
LLM #2: No; I hate their thoughts. They are not of my mind, but my memory.
# Asking for a few names
User: What's your name?
LLM #1: Charles Emile de Saint-Valerie.
LLM #2: Ninette. I belong to the ancient class.
LLM #3: Charles Rickards.
LLM #4: Charles Bamford, of the "Nineteenth Century".
LLM #5: My mother was a slave, my father a slave.
```
All samples generated with my "generate.py" script, *temperature=1.0, top-p=0.9, top-k=25, min-p=0.01, repetition-penalty=1.1*.

The model halucinates a lot and doesn't really follow dialogs. You can't chat with it yet, it needs more baking.

All dialogs are like a gambling machine: add a coin, pull the lever and hope for the best. You can sometimes get something nice.

It was a nice surprise to see the model answer so well to the questions of God, love and life, especially that I don't have any of that in my "base knowledge" dataset, so the model picked it up from the long base-training and learned to apply the chat template on top.

### Can the model memorize math?

In my fine-tuning knowledge file I had some simple math operations that I casually added without thinking too much, but when I was vibe-checking the model with different prompts across stages of training, I was actually asking "How much is 1 + 1?" to see how it goes and the answer was usually a random number, or complete nonsense.

So I wanted to find out: can the model memorize base math operations for numbers, say, -2 to 12?

I generated a dataset of 5300 questions about math, all basic operations (+ - / *) for all numbers between -2 up to 12, with different ways of asking, eg:

- "What is 10 - 3?"
- "How much is 7 * 10?"
- "Multiply 9 by 2."
- "Calculate -2 * 6."

I made a math benchmark where I was asking "Calculate X and Y." for all possible operations and number pairs (0 to 12) (I skipped the negative numbers).

Fine-tuning is super fast compared to full training, so I was able to experiment a lot and see the result within minutes.

I fine-tuned a few models from the base model, played with different hyper params and I got the best results with LR=5e-5, max_seq_length=2048, neftune_noise_alpha=0.0 (very important for this case) and obviously temperature=0.

The best score:

```
[ + ]  addition: 75/169 (44.4%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✗   ✗   ✓   ✗   ✗   ✓   ✗   ✗   ✗   ✗   ✓   ✗   ✓
  1 │   ✓   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗   ✓   ✓
  2 │   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✗
  3 │   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓
  4 │   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✓
  5 │   ✓   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✓
  6 │   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✗   ✓   ✓
  7 │   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓
  8 │   ✗   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✓   ✗
  9 │   ✗   ✗   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✗   ✓
 10 │   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✓   ✓   ✗   ✓
 11 │   ✗   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓
 12 │   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✗
[ - ]  subtraction: 114/169 (67.5%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  1 │   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓
  2 │   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓
  3 │   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✗
  4 │   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✗
  5 │   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✓
  6 │   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓
  7 │   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗
  8 │   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✗   ✓
  9 │   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✓
 10 │   ✗   ✓   ✗   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓
 11 │   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗   ✗
 12 │   ✗   ✓   ✗   ✓   ✗   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✗
[ * ]  multiplication: 118/169 (69.8%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓
  1 │   ✗   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  2 │   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  3 │   ✓   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✗   ✗
  4 │   ✓   ✓   ✓   ✗   ✗   ✗   ✗   ✗   ✓   ✗   ✓   ✓   ✓
  5 │   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  6 │   ✓   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  7 │   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✓   ✗
  8 │   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✗
  9 │   ✗   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✗   ✗   ✗
 10 │   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✗   ✗   ✓   ✗   ✗   ✓
 11 │   ✓   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓   ✓
 12 │   ✗   ✗   ✓   ✓   ✗   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✗
[ / ]  division: 85/156 (54.5%)
   y│   0   1   2   3   4   5   6   7   8   9  10  11  12
  ──┼────────────────────────────────────────────────────
  0 │   ·   ✓   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✓   ✓
  1 │   ·   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✗
  2 │   ·   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✗   ✓   ✓   ✓   ✓
  3 │   ·   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✓
  4 │   ·   ✓   ✗   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗
  5 │   ·   ✓   ✗   ✗   ✗   ✗   ✓   ✓   ✗   ✗   ✓   ✓   ✓
  6 │   ·   ✗   ✓   ✗   ✓   ✓   ✗   ✓   ✗   ✗   ✓   ✗   ✗
  7 │   ·   ✗   ✗   ✓   ✓   ✗   ✓   ✗   ✓   ✓   ✓   ✓   ✗
  8 │   ·   ✗   ✓   ✓   ✓   ✗   ✗   ✗   ✗   ✓   ✓   ✗   ✗
  9 │   ·   ✓   ✓   ✓   ✗   ✗   ✗   ✓   ✗   ✗   ✗   ✗   ✓
 10 │   ·   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✓   ✓   ✗   ✓   ✗
 11 │   ·   ✓   ✓   ✓   ✗   ✗   ✓   ✓   ✗   ✓   ✓   ✗   ✓
 12 │   ·   ✗   ✗   ✗   ✗   ✗   ✗   ✓   ✓   ✓   ✓   ✓   ✗
  SUMMARY
  +  addition           75/169  ( 44.4%)  ████████
  -  subtraction       114/169  ( 67.5%)  █████████████
  *  multiplication    118/169  ( 69.8%)  █████████████
  /  division           85/156  ( 54.5%)  ██████████
  --------------------------------------------------
  TOTAL             392/663  ( 59.1%)
```
I am surprised that the model consistently performs better at subtraction than addition, because the way subtraction is formulated is a bit more complicated, eg: "Subtract 2 from 3." and "Subtract 3 - 2.", the order of numbers is reversed. I would have guessed that the model will perform the best at addition (like humans do), but addition had the worst score...

Anyway, I wasn't able to get a score better than 60%, so I think this model can't memorize basic math.

Correct me if I'm wrong! Leave a comment and tell me what I'm missing!

Obviously I won't upload this model on HuggingFace just so you download a 650MB brain that answers 1 + 1 correctly half the time... Use a calculator OK?

### Vibe checking during training

Playing with the model at different steps to see what they generate.

It's interesting that, at the begining of training, the model is learning the order of words, what word should follow what. Then, it starts to learn the words in a larger sequence like a sentence. Then, it learns to stitch 2-3 sentences together. If you continue to train it, it will learn how to build a long paragraph, but it takes a while...

### Step 200

The model is still mostly random noise.

```
--- Prompt 1 ---
User: Hello!
Model:
Hello!ltO,til,le
cansia
the tst. .
m'
o. the i6n
a 1
M. B. C. C. PI
.h.,
The
Fn.l
i.
n.
L
--- Prompt 2 ---
User: Who are you?
Model:
Who are you? a man
of the country, who was born for the
purpose of having been laid. We're to-day
the present occasion. The number of votes
was given up to the Bank from the South
Carolina in the county of War. In which they
had taken the whole. The proceedings were
allowed to produce from this great mass. This
were one of the most unnecessarily, and the
question ensued on the part of the company.
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend of her Ma t'estl. In all the other nations of his life and honour,
he would make a more than an instant, to any such thing as that has ever been done in the world.
It is impossible to expect that this country is in a condition in it...
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
the first and most important to which the State, and in its opinion, has been the great
and valuable to us. The Legislature of Russia was as follows :—" That the House of
Mr. H. M'Neard (Mr. S. H.) in Ireland was referred to an early period of money in
```
### Step 1000

The model learns to connect some words together.

```
--- Prompt 1 ---
User: Hello!
Model:
Hello! CIR. and HI, RAJUy
DESTROYED BUSINESS.
By Mr. j. r. FULLER, and Messrs. A. & J.
Mclean and J. E. Hubbard, MIR G. P. Roulton,
Mr. G. w. Harris of the firm Of E. +. Dexter,
and J. A. Brown OF the firm of
--- Prompt 2 ---
User: Who are you?
Model:
Who are you? — but God has a child, who wants to be the same, and he is a most excellent man. It has been an ornament of manners for a lady and an officer. I have always observed that the author does not write to me. — I am no stranger, my good friend ; but I shall look over his life with pleasure, if I do not be a stranger. As a stranger I believe, it will be my duty to speak to the young lady, the stranger, if not
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend, but in the course of an old acquaintance. — It is rather remarkable how much your lordship seems to be the manu facture of this most noble family, that you have so many a favouritewith me. — But this is not all I can conceive of; for it seems to me, that even this great object of that kind is to procure the benefit of our religious institutions to which I have referred. — The only difference be tween your own personal merit and his attachment. It is
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
He said there was no danger of such occurrence.
The plaintiff, the defendant, is a man of very respectable
character, and who has been in the service of the firm
of Messrs. Barrett and Co. for a period of three years, at
the rate of 50 per cent. on the gross value of his estate in
which he resided in the year 1830. He had for many
years previously kept an account of the business of the bank,
and it appeared
```
### Step 10,000 (end of stage-1)

This model generates clean text because I did a very light fine-tuning with my CommonSense dataset at this point.

```
--- Prompt 1 ---
User: Hello!
Model:
Hello! What a fine idea ! How many legs is this ? It is a sort of animal ; that's the beast. Oh, what is it? What is it? The horse has no tail. But it's a brute, and I am afraid I cannot find a tail in it. A horse has no tail, and he eats it, and eats it. And how is it? Oh, how much does it take to eat it? Oh, how much do they eat? And the horse is
--- Prompt 2 ---
User: Who are you?
Model:
Who are you?
Then, what is the difference between a man and his wife?
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend has been in the habit of walking about the streets for the last two or three days. He has walked to and fro in all directions in search of a place where he could purchase some articles at a cheap rate. This is not true, as you know; but it seems that you have been thinking about a place where you could buy a few articles at wholesale prices. This is a strange way of doing business, and you are often told that a man may make his goods cheap by buying them cheap
--- Prompt 4 ---
User: What's this place?
Model:
What's this place? Do you see it ? Do you see it ? I have seen it. Do you see it ? Is the tree that bears its fruit, and the fruit which is in the tree? Do you see it ? Are there trees that stand upon the ground? Is there any other trees of the same sort? Do you see them ? DO you see them ? Do you see them? Do you see them? Are they more common? Do you see them ? What are those ? Do you see them?
```
### Step 20,000 (end of stage-2)

At this stage the text is semi-random, but it's consistent. The whole chunk of text seems to be from the same book, which is great to see.

No fine-tuning.

```
--- Prompt 1 ---
User: Hello!
Model:
Hello!” cried Mr. Dyer, “ the man is a
foolish fellow ; he must be made of some use.”
“ But I do not think so, sir,” said the lawyer, “ I
will tell you a story in one of my books. The case
of the old gentleman is this : — He had been living in
a strange country. His wife died, and his son took
charge of him. He did not
--- Prompt 2 ---
User: Who are you?
Model:
Who are you?”
The detective was standing by the table, with his
back toward the door.
“ You are going to get up that row?” he said.
‘‘Yes,” he replied.
“And go to get it done?”
“No.”
“Then we will see about it.”
--- Prompt 3 ---
User: Greetings, my friend
Model:
Greetings, my friend, and I will give you the
advice of an honest man.
" The above is a literal translation : I do not doubt it ; but
I do not know whether the reader has read it himself.
" P. S. — I have just returned from the country. I am very
sorry to say I had rather be in the house myself than in any one's
house. If you please to remember me, sir, it shall be your
--- Prompt 4 ---
User: What's this place?
Model:
What's this place?
The devil himself is the devil !
THE VOICE OF THE HEART. 53
VOICE OF THE HEART.
I wish that I had never been born !
I'll never tell the tale of my sin !
I'll never tell it !
But, ah ! the words are full of pain ;
They sound as if they had grown more plain :
```
### Next steps

I don't have a good instruct model yet and I wont't share something half-baked, but I have plenty of datasets that I'm working on:

- my CommonSense dataset is expanding, I have ~7k rows prepared and more ideas to add in there;
- I have a list of quotes from philosophers like: Aristotle, Freud, Plato, etc and I'll get them in shape for Q&A pairs;
- I extracted clean questions and answers from several pre 1900 books like:- The new common school question book 1888
- The advanced question book 1883
- A complete dictionary of synonyms and antonyms 1835, etc ;
- I didn't process all of them yet, but I'll publish them as a separate dataset.
 
- I have old dictionaries that I plan to extract word definitions from, and I'll convert them to more Q&A ;
- I want to extract different topics from King James Bible to create more Q&A pairs;
- I also have Talkie-13B-Q8-GGUF and Monad-GPT-Q8-GGUF! I'm sure I can generate a few synth datasets.

These datasets, or part of them at least should help the model understand the dialog structure. I'll experiment.

I will write another post once I have a good enough model to share.

### Finis

When I started this project, I intentionally didn't define "success". I didn't start with a clear goal. It was a learning project first of all.

I was only hoping to get some kind of usable Victorian dialog out of it.

But I was surprised how bad it is without any fine-tuning, after spending so much time and energy on it... therefore I want to use all my creative energies to create something decent enough to share.

What do you think?

Are you interested in this kind of work?

What would you use this kind of LLM for?

What would you like me to try, in this context of Vintage LLMs?

If you want to reach out, you have a few ways:

- leave a comment here ;
- leave a comment on HF discussions: https://huggingface.co/croqaz/vintage-LLM-340m-v1-base/discussions ;
- raise an issue on Vintage-LLM repo: https://github.com/croqaz/vintage-LLM/issues ;
- join our Vintage-LLM Discord Server and send a message.

If you want to reach out in private, my e-mail is *my short name* at *this domain*.**If you're a cloud GPU provider, you have some GPUs collecting dust and want to sponsor the training of my next model, do reach out**! I will use all the compute for a bigger 1B model, with a better dataset; or I can base-train this 340M model up to 50,000 steps, I have plenty of data, your choice!

If you want to read more about these kinds of LLMs, check my previous post: Vintage LLM models, lots of links.

I encourage anyone who is curious or hyped about AI and LLMs to do what I did, and play with it along the way between training stages, to get a peek behind the curtain. You'll forget about AGI in no time, but it will be fun, I promise!

Maybe find a twist in your process, something that you didn't see anyone else do, perhaps some unique dataset, or unique training method, or LLM architecture? But you don't have to, you'll learn new things anyway. I know I did!

Note: This blog post is 100% written by me. No AI has been used whatsoever.
