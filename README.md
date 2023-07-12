<h1 align="center">
<br> Otimização Combinatória
</h1>
Repositório para as tarefas da Disciplina de Otimização Combinatória no <a href="https://www.cos.ufrj.br/" >Programa de Engenharia de Sistemas e Computação</a> da <a href="https://ufrj.br/" >UFRJ - Universidade Federal do Rio de Janeiro</a>, ministrada pelo <a href="https://www.cos.ufrj.br/index.php/pt-BR/pessoas/details/18/2201-abiliolucena">Prof. Abílio Lucena</a>.

Desenvolvido por Ronald Albert.
<h2 align="center">
A linguagem Julia
</h2>
Todo o repositório está implemetado na linguagem <a href="https://julialang.org/">Julia</a>. A execução do projeto tem como dependências as seguintes bibliotecas da linguagem:
<ul>
    <li><a href="https://github.com/jump-dev/JuMP.jl">JuMP.jl</a></li>
    <li><a href="https://github.com/jump-dev/HiGHS.jl">HiGHS.jl</a></li>
    <li><a href="https://github.com/matago/TSPLIB.jl">TSPLIB.jl</a></li>
</ul>


<h2 align="center">
Módulos
</h2>
O repositório é composto por 2 módulos referentes a lista 1, presentes em  <strong>src/Lista1</strong>, são eles <strong> LSP.jl </strong> e <strong>TSP.jl</strong>.

<ul>
<li><h3>LSP.jl</h3></li>
Implementação do problema de dimensionamento de lotes. O módulo conta com uma estrutura <code>LSP(n_periods, d, p, h, f, M)</code> onde as instâncias do problema podem ser modeladas. Para a execução e avaliação da instâncias definida no Exercício 13 do Capítulo 1 do livro-texto <a href="https://onlinelibrary.wiley.com/doi/book/10.1002/9781119606475">Integer Programming</a> é necessário executar o seguinte comando:
   
```console
julia src/Lista1/LSP.jl
```

<li><h3>TSP.jl</h3></li>
Implementação do problema do caixeiro viajante em Julia. O módulo conta com uma estrutura <code>TSP(n_nodes,adj_matrix,precende_restrictions)</code> onde as instâncias do problema podem ser modeladas. Para a execução e avaliação de algumas instâncias disponíveis na biblioteca <strong>TSPLIB.jl</strong> é necessário executar o seguinte comando:

```console
julia src/Lista1/TSP.jl
```
    
</ul>
