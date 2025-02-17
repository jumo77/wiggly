export const processLog = (userLog) => {
    const c = {
        totalCounts: {
            title: '전체 사용자 통계',
            selection: 'haha'
        },
        monthlyCounts: {
            title: '월간 사용자 통계',
            selection: 'monthlyCounts'
        },
        dailyCounts: {
            title: '일간 사용자 통계',
            selection: 'dailyCounts',
        },
    }

    for (const item of userLog) {
        const date = new Date(item.first); // Date 타입 필드 이름에 따라 수정
        const year = date.getFullYear();
        const month = date.getMonth() + 1; // 0부터 시작하므로 1을 더함
        const day = date.getDate();

        const keys = {
            dailyCounts: `${year}-${month}-${day}`,
            monthlyCounts: `${year}-${month}`,
            totalCounts: 'total'
        }

        for (const key in c) {
            const i = c[key][keys[key]] || {new: 0, active: 0, re: 0};
            c[key][keys[key]] = {
                new: i.new + 1,
                active: i.active + (item.visited >= 3 ? 1 : 0),
                re: i.re + (dayPassed(item) ? 1 : 0),
            };
        }
    }
    return c
}

const dayPassed = (userLog) => {
    const date1 = new Date(userLog.start);
    const date2 = new Date(userLog.last);

    const diffInMilliseconds = Math.abs(date2.getTime() - date1.getTime());
    const diffInDays = Math.ceil(diffInMilliseconds / (1000 * 60 * 60 * 24));

    return diffInDays >= 1;
}