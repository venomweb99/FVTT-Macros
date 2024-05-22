let hopeDie = await new Roll("1d12").evaluate();
let fearDie = await new Roll('1d12').evaluate();

let total = hopeDie.total + fearDie.total;
let result = "";
let dcolor = "";
let tcolor = "";

if (hopeDie.total > fearDie.total) {
    result = `${total} with HOPE`;
    dcolor = getComputedStyle(document.documentElement).getPropertyValue('--header-color');
    tcolor = getComputedStyle(document.documentElement).getPropertyValue('--title-text-color');
} else if (fearDie.total > hopeDie.total) {
    result = `${total} with FEAR`;
    dcolor = getComputedStyle(document.documentElement).getPropertyValue('--background-color');
    tcolor = getComputedStyle(document.documentElement).getPropertyValue('--text-color');
} else {
    result = `${total} CRITICAL!`;
}

const data = {
    throws:[{
        dice:[
            {
                result:hopeDie.total,
                resultLabel:hopeDie.total,
                type: "d12",
                vectors:[],
                options:{}
            },
            {
                result:fearDie.total,
                resultLabel:fearDie.total,
                type: "d12",
                vectors:[],
                options:{}
            }
        ]
    }]
};
await game.dice3d.show(data).then(displayed => { console.log("Animation ended")  }); 



let msg = await ChatMessage.create({ content: 

`
        <div style="text-align: center;">
            <div style="display: flex; justify-content: space-between;">
                <div style="border: 2px solid var(--active-color); border-radius: var(--border-r); padding: var(--spacing); margin-right: var(--spacing); background: var(--header-color); color: var(--title-text-color);">HOPE: ${hopeDie.total}</div>
                <div style="border: 2px solid var(--active-color); border-radius: var(--border-r); padding: var(--spacing); background: var(--background-color); color: var(--text-color);">FEAR: ${fearDie.total}</div>
            </div>
            <div style="font-size: 40px; border: 2px solid var(--active-color); border-radius: 50%; width: 100px; height: 100px; margin: 20px auto; background: ${dcolor}; color: ${tcolor};">
                <div style="margin-top: 25%;">${total}</div>
            </div>
            <div style="font-style: italic; font-size: 18px;">${result}</div>
        </div>
`

});