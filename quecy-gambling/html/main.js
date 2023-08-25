$(() => {

    const Show = (state) => {
        switch (state) {
            case true:
                $("body").fadeIn(300);
                break;
            case false:
                $("body").fadeOut(300);
                break;
        }
    }

    const CreateOption = (button) => {
        let option = `
            <div class="dialog">
                <div class="icon">
                    <i class="fas fa-${button.icon}"></i>
                </div>
                <div class="text">
                    <span>${button.translate}</span>
                </div>
            </div>
        `,

            createdOption = $(option)

        $(".npcdialog-body").append(createdOption)

        createdOption.click(e => {
            $.post(`https://quecy-gambling/yes`, JSON.stringify({ button }))
        })

    }

    const InitNPC = (data) => {
        $("#npcName").text(`${data.npcName}: `)
        $("#npcText").text(data.text)
        data.ui.forEach(button => {
            if (!button.icon) return;
            CreateOption(button)
        })
        Show(true)
    }

    window.addEventListener("message", e => {
        let data = e.data

        switch (data.action) {
            case "openDialog":
                $(".npcdialog-body").empty()
                InitNPC(data)
                break;
            case "closeDialog":
                $(".npcdialog-body").empty()
                Show(false);
                break;
        }
    })

    window.addEventListener("keyup", e => {
        if (e.key === "Escape") {
            $.post("https://quecy-gambling/closeDialog", JSON.stringify({}))
        }
    })
})