# Publications

## Citing CHASE

To cite CHASE, please use the DATE 2018 paper:

```bibtex
@inproceedings{CHASE:2018:DATE,
  title={CHASE: Contract-based requirement engineering for cyber-physical system design},
  author={Nuzzo, Pierluigi and Lora, Michele and Feldman, Yishai A and Sangiovanni-Vincentelli, Alberto L},
  booktitle={Proceedings of the Design, Automation \& Test in Europe Conference \& Exhibition (DATE) 2018},
  pages={839--844},
  year={2018},
  organization={IEEE}
}
```

## Papers

### The framework

- Pierluigi Nuzzo, Michele Lora, Yishai A. Feldman, Alberto
  Sangiovanni-Vincentelli. *CHASE: Contract-Based Requirement Engineering for
  Cyber-Physical System Design*. Design, Automation and Test in Europe
  (DATE), 2018.
  [PDF](https://past.date-conference.com/proceedings-archive/2018/pdf/0451.pdf)
  The specification files of its experiments are in the `DATE18` directory
  of the [demos](https://github.com/chase-cps/demos).
- Michele Lora, Pierluigi Nuzzo. *A Contract-Based Requirement Engineering
  Framework for the Design of Industrial Cyber-Physical Systems*.
  Work-in-Progress, ACM/IEEE International Conference on Cyber-Physical
  Systems (ICCPS), 2022, within the [DeFacto](https://defacto-h2020.github.io/)
  project. [DOI](https://doi.org/10.1109/ICCPS54341.2022.00046)
  [PDF](https://iris.univr.it/bitstream/11562/1077207/1/ICCPS_22_WiP_CHASE.pdf)

### Design-space exploration

- Yifeng Xiao, Pierluigi Nuzzo. *Contract-Based Architecture Exploration of
  Cyber-Physical Systems via Satisfiability Modulo Convex Programming*.
  Design, Automation and Test in Europe (DATE), 2026.
  [DOI](https://doi.org/10.23919/DATE69613.2026.11539305). The contracts are
  written and composed with CHASE.
- Yifeng Xiao, Chanwook Oh, Michele Lora, Pierluigi Nuzzo. *Efficient
  Exploration of Cyber-Physical System Architectures Using Contracts and
  Subgraph Isomorphism*. Design, Automation and Test in Europe (DATE), 2024.
  Best Paper Award. [IEEE](https://ieeexplore.ieee.org/document/10546764).
  The exploration tool, ContrArc, is built on the CHASE library.
- Christopher Leet, Chanwook Oh, Michele Lora, Sven Koenig, Pierluigi Nuzzo.
  *Co-Design of Topology, Scheduling, and Path Planning in Automated
  Warehouses*. Design, Automation and Test in Europe (DATE), 2023.
  [DOI](https://doi.org/10.23919/DATE56975.2023.10137069). The contracts of
  the components and of the workload are compiled and composed with CHASE.

### Timing of distributed systems

- Yifeng Xiao, Charles D. Lutz, Mauricio Castillo-Effen, Pierluigi Nuzzo.
  *Contract-Based Consistency and Availability Analysis for Distributed
  Cyber-Physical Systems*. International Symposium on Formal Methods and
  Models for System Design (MEMOCODE), 2026.
  [Program](https://memocode2026.github.io/program.html). The timing
  contracts are written with the Python interface of CHASE; the demos
  [Drone timing](demos/drone-timing.md) and
  [Fire-suppression drones in C](demos/drone-grid.md) follow it.

### AI agents

- Yifeng Xiao, Pierluigi Nuzzo. *Symbolic Temporal Supervision of LLM Agents
  Using Contracts*. arXiv 2609.18128, 2026.
  [arXiv](https://arxiv.org/abs/2609.18128). The contract libraries of its
  supervisor, ContrAgent, are exported to CHASE for analysis at design time.

### Industrial systems

- Michele Lora, Sebastiano Gaiardelli, Chanwook Oh, Stefano Spellini,
  Pierluigi Nuzzo, Franco Fummi. *Design Automation for Cyber-Physical
  Production Systems: Lessons Learned from the DeFacto Project*. Design,
  Automation and Test in Europe (DATE), 2024.
  [DOI](https://doi.org/10.23919/DATE58400.2024.10546563). The methods of the
  project are implemented in CHASE.

## Demonstrations

- DATE 2021 University Booth: the two flows of CHASE, the domain-specific
  language and the logic-based language
  ([walkthrough](https://github.com/chase-cps/demos/blob/main/DATE21/DATE21.md)).
- CPS-IoT Week 2022: verification and synthesis of the controller of a
  robotic arm, with a single model and with a compositional model
  ([robotic joints](demos/robotic-joints.md)).

## Acknowledgement

We acknowledge the support of the National Science Foundation (awards 1846524
and 2139982), the Office of Naval Research (award N00014-20-1-2258), the
Defense Advanced Research Projects Agency (award HR00112010003), the Okawa
Foundation, and the European Union's Horizon 2020 research and innovation
program under the
[Marie Sklodowska-Curie grant agreement No. 894237](https://cordis.europa.eu/project/id/894237).
