clear all
set more off

* 导入 CSV：若文件名或位置不同，请修改路径
* case(lower) 将列名统一为小写，方便后续命令使用
import delimited using "/Users/mujunlin/Desktop/ECO205学历与收入_含受教育时间.csv", clear varnames(1) encoding("utf-8") case(lower)

* 检查变量及学历分类
describe
tabulate education, missing
summarize pincp wagp agep

* 本代码选择个人总收入 PINCP，正收入才可以取对数
* 若你们研究工资收入，应将下面两处 pincp 改为 wagp
generate double ln_income = ln(pincp) if pincp > 0 & pincp < .

* 将分类编码转换为容易解释的虚拟变量
* DIS：1 表示有残障，2 表示无残障
generate byte disability = (dis == 1) if inlist(dis, 1, 2)

* HISP：1 表示非西班牙裔，其他有效类别表示西班牙裔
generate byte hispanic = (hisp > 1) if !missing(hisp)

* 三个模型使用相同的完整样本，便于比较系数
generate byte sample_common = !missing(ln_income, master, professional, doctorate, agep, female, disability, rac1p, hispanic, state)

* Model 1：学历与收入，本科为参照组
regress ln_income master professional doctorate if sample_common, vce(robust)
estimates store M1

* Model 2：加入年龄、年龄平方和性别
* c.agep#c.agep 表示年龄平方，无需另外生成变量
regress ln_income master professional doctorate c.agep c.agep#c.agep female if sample_common, vce(robust)
estimates store M2

* Model 3：进一步控制残障、种族、西班牙裔和州
* i. 表示按类别生成虚拟变量，不把编码当作连续数值
regress ln_income master professional doctorate c.agep c.agep#c.agep female disability i.rac1p hispanic i.state if sample_common, vce(robust)
estimates store M3

* 检验三个学历变量是否联合显著
test master professional doctorate

* 将三个模型并排展示，报告系数、稳健标准误、样本量和 R²
estimates table M1 M2 M3, b(%9.4f) se(%9.4f) stats(N r2)

* Model 3：计算相对于本科的收入百分比差异
nlcom (Master_pct: 100*(exp(_b[master])-1)) (Professional_pct: 100*(exp(_b[professional])-1)) (Doctorate_pct: 100*(exp(_b[doctorate])-1))
