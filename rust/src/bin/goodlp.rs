use std::iter::Sum;

use good_lp::{Expression, Solution, SolverModel, constraint, default_solver, variable, variables};

fn main() {
    {
        let mut vars = variables!();
        let a1 = vars.add(variable().integer().min(0));
        let a2 = vars.add(variable().integer().min(0));
        let a3 = vars.add(variable().integer().min(0));
        let a4 = vars.add(variable().integer().min(0));
        let a5 = vars.add(variable().integer().min(0));
        let a6 = vars.add(variable().integer().min(0));

        let solution = vars
            .minimise(a1 + a2 + a3 + a4 + a5 + a6) // Objective: Minimize sum
            .using(default_solver) // Use the HiGHS solver
            .with(constraint!(a5 + a6 == 3))
            .with(constraint!(a2 + a6 == 5))
            .with(constraint!(a3 + a3 + a4 + a5 == 4))
            .with(constraint!(a1 + a2 + a4 == 7))
            .solve();

        match solution {
            Ok(sol) => {
                println!("Optimal a1: {}", sol.value(a1));
                println!("Optimal a2: {}", sol.value(a2));
                println!("Optimal a3: {}", sol.value(a3));
                println!("Optimal a4: {}", sol.value(a4));
                println!("Optimal a5: {}", sol.value(a5));
                println!("Optimal a6: {}", sol.value(a6));
                println!("Minimal Sum: {}", sol.eval(a1 + a2 + a3 + a4 + a5 + a6));
            }
            Err(e) => println!("Solving failed: {:?}", e),
        }
    }
    {
        let mut vars = variables!();
        let a1 = vars.add(variable().integer().min(0));
        let a2 = vars.add(variable().integer().min(0));
        let a3 = vars.add(variable().integer().min(0));
        let a4 = vars.add(variable().integer().min(0));
        let a5 = vars.add(variable().integer().min(0));

        let terms = [
            &[a1, a3, a4][..],
            &[a4, a5],
            &[a1, a2, a4, a5],
            &[a1, a2, a5],
            &[a1, a3, a5],
        ];
        let subject = [a1, a2, a3, a4, a5];
        let sums = [7, 5, 12, 7, 2];
        // let term1 = [a1, a3, a4];
        let mut model = vars
            // .minimise(a1 + a2 + a3 + a4 + a5) // Objective: Minimize sum
            .minimise(Expression::sum(subject.iter()))
            .using(default_solver); // Use the HiGHS solver

        for (t, s) in terms.iter().zip(sums.iter()) {
            model = model.with(constraint::eq(Expression::sum(t.iter()), *s));
        }

        let solution = model.solve();
        // .with(good_lp::constraint::eq(Expression::sum(term1.iter()), 7))
        // // .with(constraint!(a1 + a3 + a4 == 7))
        // .with(constraint!(a4 + a5 == 5))
        // .with(constraint!(a1 + a2 + a4 + a5 == 12))
        // .with(constraint!(a1 + a2 + a5 == 7))
        // .with(constraint!(a1 + a3 + a5 == 2))
        // .solve();

        match solution {
            Ok(sol) => {
                println!("Optimal a1: {}", sol.value(a1));
                println!("Optimal a2: {}", sol.value(a2));
                println!("Optimal a3: {}", sol.value(a3));
                println!("Optimal a4: {}", sol.value(a4));
                println!("Optimal a5: {}", sol.value(a5));
                println!("Minimal Sum: {}", sol.eval(a1 + a2 + a3 + a4 + a5));
            }
            Err(e) => println!("Solving failed: {:?}", e),
        }
    }
}
